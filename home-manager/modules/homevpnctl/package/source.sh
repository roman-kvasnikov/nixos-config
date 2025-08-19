#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly CONFIG_DIR="@configDirectory@/homevpn"
readonly VPN_CONNECTION_NAME="Home-L2TP-IPSec"
readonly STATUS_FILE="$CONFIG_DIR/.vpn-status"
readonly CONNECTION_LOG="$CONFIG_DIR/connection.log"

# Цвета для вывода (ANSI escape codes)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# УТИЛИТЫ ДЛЯ ВЫВОДА
# =============================================================================

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_status() {
    echo -e "${CYAN}$1${NC}"
}

# =============================================================================
# ВАЛИДАЦИЯ И ПРОВЕРКИ
# =============================================================================

# Проверить наличие необходимых команд
check_dependencies() {
    local missing_deps=()
    
    if ! command -v nmcli >/dev/null 2>&1; then
        missing_deps+=("nmcli")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure NetworkManager and jq are installed"
        exit 1
    fi
}

# Проверить, что скрипт запущен от имени пользователя
check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# =============================================================================
# РАБОТА С КОНФИГУРАЦИЕЙ
# =============================================================================

# Создать конфигурационный файл из примера, если его нет
ensure_config() {
    mkdir -p "$CONFIG_DIR"

    if [ ! -f "@configFile@" ]; then
        local example_file="@configDirectory@/homevpn/config.example.json"
        
        if [ ! -f "$example_file" ]; then
            print_error "Example config file not found: $example_file"
            exit 1
        fi
        
        print_info "Creating default config from example..."
        cp "$example_file" "@configFile@"
        print_success "Config created at: @configFile@"
    fi
}

# Получить настройки VPN из config.json
get_vpn_config() {
    local field="$1"  # "server", "login", "password", "psk"
    
    if [ ! -f "@configFile@" ]; then
        return 1
    fi
    
    jq -r ".$field // empty" "@configFile@" 2>/dev/null
}

# Проверить валидность конфигурации VPN
validate_config() {
    local server login password psk
    
    server=$(get_vpn_config "server")
    login=$(get_vpn_config "login")
    password=$(get_vpn_config "password")
    psk=$(get_vpn_config "psk")
    
    if [ -z "$server" ] || [ "$server" = "null" ]; then
        print_error "VPN server not configured"
        return 1
    fi
    
    if [ -z "$login" ] || [ "$login" = "null" ]; then
        print_error "VPN login not configured"
        return 1
    fi
    
    if [ -z "$password" ] || [ "$password" = "null" ]; then
        print_error "VPN password not configured"
        return 1
    fi
    
    if [ -z "$psk" ] || [ "$psk" = "null" ]; then
        print_warning "No PSK configured - connection might fail"
    fi
    
    return 0
}

# Создать NetworkManager L2TP соединение
create_vpn_connection() {
    local server login password psk
    
    server=$(get_vpn_config "server")
    login=$(get_vpn_config "login")  
    password=$(get_vpn_config "password")
    psk=$(get_vpn_config "psk")
    
    print_info "Creating L2TP/IPsec VPN connection: $VPN_CONNECTION_NAME"
    
    # Удалить существующее подключение если есть
    if nmcli connection show "$VPN_CONNECTION_NAME" >/dev/null 2>&1; then
        nmcli connection delete "$VPN_CONNECTION_NAME" >/dev/null 2>&1 || true
    fi
    
    # Создать новое L2TP подключение
    nmcli connection add \
        type vpn \
        con-name "$VPN_CONNECTION_NAME" \
        vpn-type l2tp \
        vpn.data "gateway=$server,user=$login,password-flags=0" \
        vpn.secrets "password=$password" \
        >/dev/null 2>&1
    
    # Добавить IPsec настройки если есть PSK
    if [ -n "$psk" ] && [ "$psk" != "null" ]; then
        nmcli connection modify "$VPN_CONNECTION_NAME" \
            vpn.data "gateway=$server,user=$login,password-flags=0,ipsec-enabled=yes,ipsec-psk=$psk,ipsec-disable-pfs=yes" \
            >/dev/null 2>&1
    fi
    
    print_success "VPN connection created successfully"
}

# =============================================================================
# УПРАВЛЕНИЕ VPN СОЕДИНЕНИЕМ
# =============================================================================

# Проверить статус VPN соединения
get_vpn_status() {
    local connection_state
    
    if ! nmcli connection show "$VPN_CONNECTION_NAME" >/dev/null 2>&1; then
        echo "not_configured"
        return
    fi
    
    connection_state=$(nmcli -t -f GENERAL.STATE connection show "$VPN_CONNECTION_NAME" 2>/dev/null | cut -d: -f2)
    
    case "$connection_state" in
        "activated")
            echo "connected"
            ;;
        "activating")
            echo "connecting"
            ;;
        *)
            echo "disconnected"
            ;;
    esac
}

# Записать статус в файл
write_status() {
    local status="$1"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$status|$timestamp" > "$STATUS_FILE"
}

# Получить сохраненный статус
read_status() {
    if [ -f "$STATUS_FILE" ]; then
        cut -d'|' -f1 "$STATUS_FILE"
    else
        echo "unknown"
    fi
}

# Логирование подключений
log_connection() {
    local action="$1"
    local timestamp status
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    status=$(get_vpn_status)

    mkdir -p "$CONFIG_DIR"

    echo "[$timestamp] $action - Status: $status" >> "$CONNECTION_LOG"
}

# Подключиться к VPN
connect_vpn() {
    local current_status
    
    current_status=$(get_vpn_status)
    
    case "$current_status" in
        "not_configured")
            print_info "VPN connection not configured, creating..."
            create_vpn_connection
            ;;
        "connected")
            print_warning "VPN already connected"
            return 0
            ;;
        "connecting")
            print_warning "VPN connection already in progress"
            return 0
            ;;
    esac
    
    print_info "Connecting to VPN: $VPN_CONNECTION_NAME"
    
    if nmcli connection up "$VPN_CONNECTION_NAME" >/dev/null 2>&1; then
        write_status "connected"
        log_connection "CONNECT"
        print_success "VPN connected successfully"
        
        # Показать информацию о подключении
        local server
        server=$(get_vpn_config "server")
        print_info "Connected to server: $server"
    else
        write_status "failed"
        log_connection "CONNECT_FAILED"
        print_error "Failed to connect to VPN"
        return 1
    fi
}

# Отключиться от VPN
disconnect_vpn() {
    local current_status
    
    current_status=$(get_vpn_status)
    
    if [ "$current_status" = "not_configured" ]; then
        print_warning "VPN connection not configured"
        return 0
    fi
    
    if [ "$current_status" = "disconnected" ]; then
        print_warning "VPN already disconnected"
        return 0
    fi
    
    print_info "Disconnecting from VPN: $VPN_CONNECTION_NAME"
    
    if nmcli connection down "$VPN_CONNECTION_NAME" >/dev/null 2>&1; then
        write_status "disconnected"
        log_connection "DISCONNECT"
        print_success "VPN disconnected successfully"
    else
        print_error "Failed to disconnect from VPN"
        return 1
    fi
}


# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Обработка команд
main() {
    local command="${1:-}"
    
    case "$command" in
        start|connect)
            ensure_config
            validate_config || exit 1
            connect_vpn
            ;;
        stop|disconnect)
            disconnect_vpn
            ;;
        restart)
            ensure_config
            validate_config || exit 1
            print_header "🔄 Restarting VPN connection..."
            disconnect_vpn
            sleep 2
            connect_vpn
            ;;
        status)
            print_header "🔍 Home VPN Status:"
            local current_status server
            current_status=$(get_vpn_status)
            
            case "$current_status" in
                "connected")
                    server=$(get_vpn_config "server")
                    print_success "VPN Status: CONNECTED to $server"
                    
                    # Показать IP информацию
                    local vpn_ip
                    vpn_ip=$(nmcli -t -f IP4.ADDRESS connection show "$VPN_CONNECTION_NAME" 2>/dev/null | cut -d: -f2 | head -1)
                    if [ -n "$vpn_ip" ]; then
                        print_info "VPN IP: $vpn_ip"
                    fi
                    ;;
                "connecting")
                    print_warning "VPN Status: CONNECTING..."
                    ;;
                "disconnected")
                    print_status "VPN Status: DISCONNECTED"
                    ;;
                "not_configured")
                    print_warning "VPN Status: NOT CONFIGURED"
                    print_info "Run 'homevpnctl start' to create and connect"
                    ;;
                *)
                    print_error "VPN Status: UNKNOWN"
                    ;;
            esac
            
            # Показать информацию о systemd сервисе
            echo ""
            print_header "📋 Systemd Service Status:"
            systemctl --user status homevpnctl --no-pager -l || true
            ;;
        logs)
            print_header "📋 Home VPN Logs:"
            if [ -f "$CONNECTION_LOG" ]; then
                print_info "Connection history:"
                tail -20 "$CONNECTION_LOG"
                echo ""
            fi
            print_info "Systemd service logs:"
            journalctl --user -u homevpnctl -f --no-pager
            ;;
        enable)
            ensure_config
            systemctl --user enable homevpnctl
            print_success "Home VPN service enabled for autostart"
            ;;
        disable)
            systemctl --user disable homevpnctl
            print_success "Home VPN service disabled from autostart"
            ;;
        config)
            ensure_config
            print_header "🔧 Home VPN Configuration:"
            print_info "Config file: @configFile@"
            print_info "Example file: @configDirectory@/homevpn/config.example.json"
            
            if [ -f "@configFile@" ]; then
                echo ""
                print_info "Current configuration:"
                local server login
                server=$(get_vpn_config "server")
                login=$(get_vpn_config "login")
                
                if [ -n "$server" ]; then
                    print_status "  Server: $server"
                fi
                if [ -n "$login" ]; then
                    print_status "  Login: $login"
                fi
                print_status "  Password: [configured]"
                
                local psk
                psk=$(get_vpn_config "psk")
                if [ -n "$psk" ] && [ "$psk" != "null" ]; then
                    print_status "  PSK: [configured]"
                else
                    print_warning "  PSK: [not configured]"
                fi
            fi
            ;;
        recreate)
            ensure_config
            validate_config || exit 1
            print_header "🔧 Recreating VPN connection..."
            create_vpn_connection
            ;;
        service-start)
            systemctl --user start homevpnctl
            print_success "Home VPN systemd service started"
            ;;
        service-stop)
            systemctl --user stop homevpnctl
            print_success "Home VPN systemd service stopped"
            ;;
        service-restart)
            systemctl --user restart homevpnctl
            print_success "Home VPN systemd service restarted"
            ;;
        clean)
            print_header "🧹 Cleaning up VPN configuration..."
            
            # Остановить соединение
            disconnect_vpn
            
            # Удалить NetworkManager подключение
            if nmcli connection show "$VPN_CONNECTION_NAME" >/dev/null 2>&1; then
                nmcli connection delete "$VPN_CONNECTION_NAME" >/dev/null 2>&1
                print_success "Removed NetworkManager connection"
            fi
            
            # Очистить файлы статуса и логи
            rm -f "$STATUS_FILE" "$CONNECTION_LOG"
            print_success "Cleaned up status and log files"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# Показать справку
show_help() {
    print_header "🏠 Home VPN L2TP/IPsec Management Tool"
    echo ""
    print_info "Usage: homevpnctl {command}"
    echo ""
    
    print_status "🚀 Quick commands:"
    echo -e "  ${GREEN}start${NC}, ${GREEN}connect${NC}         Connect to Home VPN"
    echo -e "  ${RED}stop${NC}, ${RED}disconnect${NC}       Disconnect from Home VPN"
    echo -e "  ${CYAN}restart${NC}                Reconnect to Home VPN"
    echo ""
    
    print_status "⚙️  VPN management:"
    echo -e "  ${BLUE}status${NC}                 Show VPN connection status"
    echo -e "  ${CYAN}logs${NC}                   Show connection logs"
    echo -e "  ${YELLOW}recreate${NC}              Recreate NetworkManager connection"
    echo -e "  ${RED}clean${NC}                  Clean up all VPN configuration"
    echo ""
    
    print_status "🔧 Service management:"
    echo -e "  ${GREEN}service-start${NC}          Start systemd service"
    echo -e "  ${RED}service-stop${NC}           Stop systemd service"
    echo -e "  ${CYAN}service-restart${NC}        Restart systemd service"
    echo -e "  ${GREEN}enable${NC}                 Enable autostart"
    echo -e "  ${RED}disable${NC}                Disable autostart"
    echo ""
    
    print_status "📋 Configuration:"
    echo -e "  ${PURPLE}config${NC}                 Show config file paths and settings"
    echo ""
    
    print_status "💡 Example usage:"
    echo -e "  homevpnctl start           # Connect to VPN"
    echo -e "  homevpnctl status          # Check connection status"
    echo -e "  homevpnctl logs            # View connection logs"
    echo -e "  homevpnctl stop            # Disconnect from VPN"
    echo ""
    
    print_info "Configuration file: @configFile@"
    print_info "Required format: {\"server\": \"vpn.example.com\", \"login\": \"user\", \"password\": \"pass\", \"psk\": \"key\"}"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"