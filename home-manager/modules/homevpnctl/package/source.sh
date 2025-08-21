#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly CONFIG_DIR="@configDirectory@"
readonly CONFIG_FILE="@configFile@"
readonly LOG_FILE="$CONFIG_DIR/connections.log"
readonly PID_FILE="$CONFIG_DIR/.daemon.pid"

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

# Проверить, что скрипт запущен не от root
check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Проверить наличие необходимых зависимостей
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
        print_error "Make sure nmcli and jq are installed"
        exit 1
    fi
}

# =============================================================================
# РАБОТА С КОНФИГУРАЦИЕЙ
# =============================================================================

# Создать конфигурационный файл из примера, если его нет
ensure_config() {
    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$CONFIG_FILE" ]; then
        local example_file="$CONFIG_DIR/config.example.json"

        if [ ! -f "$example_file" ]; then
            print_error "Example config file not found: $example_file"
            exit 1
        fi

        print_info "Creating default config from example..."
        cp "$example_file" "$CONFIG_FILE"
        print_success "Config created at: $CONFIG_FILE"
    fi
}

# Получить настройки из config.json (поддерживает вложенные пути)
get_config_value() {
    local field="$1"  # "vpn.server", "vpn.login", "healthcheck.enabled", "name"

    ensure_config

    # Используем jq для получения значения по пути (поддерживает точечную нотацию)
    jq -r ".$field // empty" "$CONFIG_FILE" 2>/dev/null
}

# Получить имя VPN соединения из конфигурации
get_vpn_connection_name() {
    local name
    name=$(get_config_value "name")

    if [ -n "$name" ] && [ "$name" != "null" ]; then
        echo "$name"
    else
        print_error "VPN name not configured"
        exit 1
    fi
}

# Получить настройки VPN из конфигурации
get_vpn_config() {
    local field="$1"  # "server", "login", "password", "psk"
    local value

    value=$(get_config_value "vpn.$field")

    case "$field" in
        "server"|"login"|"password")
            # Валидация обязательных строковых значений
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                echo "$value"
            else
                print_error "VPN $field not configured"
                exit 1
            fi
            ;;
        "psk")
            # PSK может быть пустым (опциональное поле)
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                echo "$value"
            else
                echo ""
            fi
            ;;
        *)
            print_error "Invalid VPN config field: $field"
            exit 1
            ;;
    esac
}

# Получить настройки healthcheck из конфигурации
get_healthcheck_config() {
    local field="$1"  # "enabled", "interval"
    local value

    value=$(get_config_value "healthcheck.$field")

    case "$field" in
        "enabled")
            # Валидация булевого значения
            if [ "$value" = "true" ] || [ "$value" = "false" ]; then
                echo "$value"
            else
                print_error "Invalid healthcheck config field: $field"
                exit 1
            fi
            ;;
        "interval")
            # Валидация числового значения
            if [ -n "$value" ] && [ "$value" != "null" ] && [ "$value" -gt 0 ] && [ "$value" -eq "$value" ] 2>/dev/null; then
                echo "$value"
            else
                print_error "Invalid healthcheck config field: $field"
                exit 1
            fi
            ;;
        *)
            print_error "Invalid healthcheck config field: $field"
            exit 1
            ;;
    esac
}

# Создать NetworkManager L2TP соединение
create_vpn_connection() {
    local name server login password psk

    name=$(get_vpn_connection_name)

    server=$(get_vpn_config "server")
    login=$(get_vpn_config "login")
    password=$(get_vpn_config "password")
    psk=$(get_vpn_config "psk")

    print_info "Creating L2TP/IPsec VPN connection: $name ..."

    # Удалить существующее подключение если есть
    if nmcli connection show "$name" >/dev/null 2>&1; then
        nmcli connection delete "$name" >/dev/null 2>&1 || true
    fi

    # Создать новое L2TP подключение
    nmcli connection add \
        type vpn \
        con-name "$name" \
        vpn-type l2tp \
        vpn.data "gateway=$server,user=$login,password-flags=0" \
        vpn.secrets "password=$password" \
        >/dev/null 2>&1

    # Добавить IPsec настройки если есть PSK
    if [ -n "$psk" ] && [ "$psk" != "null" ]; then
        nmcli connection modify "$name" \
            vpn.data "gateway=$server,user=$login,password-flags=0,ipsec-enabled=yes,ipsec-psk=$psk,ipsec-pfs=no" \
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

    if ! nmcli connection show "$(get_vpn_connection_name)" >/dev/null 2>&1; then
        echo "not_configured"
        return
    fi

    connection_state=$(nmcli -t -f GENERAL.STATE connection show "$(get_vpn_connection_name)" 2>/dev/null | cut -d: -f2)

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

# Логирование подключений
log_connection() {
    local action="$1"
    local timestamp status

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    status=$(get_vpn_status)

    mkdir -p "$CONFIG_DIR"

    echo "[$timestamp] $action - Status: $status" >> "$LOG_FILE"
}

# Подключиться к VPN
connect_vpn() {
    local status=$(get_vpn_status)

    case "$status" in
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

    print_info "Connecting to VPN: $(get_vpn_connection_name)"

    if nmcli connection up "$(get_vpn_connection_name)" >/dev/null 2>&1; then
        log_connection "CONNECTED"
        print_success "VPN connected successfully"

        # Показать информацию о подключении
        print_info "Connected to server: $(get_vpn_config "server")"
    else
        log_connection "CONNECTION_FAILED"
        print_error "Failed to connect to VPN"
        return 1
    fi
}

# Отключиться от VPN
disconnect_vpn() {
    local status=$(get_vpn_status)

    if [ "$status" = "not_configured" ]; then
        print_warning "VPN connection not configured"
        return 0
    fi

    if [ "$status" = "disconnected" ]; then
        print_warning "VPN already disconnected"
        return 0
    fi

    print_info "Disconnecting from VPN: $(get_vpn_connection_name)"

    if nmcli connection down "$(get_vpn_connection_name)" >/dev/null 2>&1; then
        log_connection "DISCONNECTED"
        print_success "VPN disconnected successfully"
    else
        print_error "Failed to disconnect from VPN"
        return 1
    fi
}

# Функция очистки при завершении
cleanup() {
    print_header "🧹 Cleaning up VPN configuration..."

    # Остановить соединение
    disconnect_vpn

    # Удалить NetworkManager подключение
    if nmcli connection show "$(get_vpn_connection_name)" >/dev/null 2>&1; then
        nmcli connection delete "$(get_vpn_connection_name)" >/dev/null 2>&1
        print_success "Removed NetworkManager connection"
    fi

    # Удалить логи
    [ -f "$LOG_FILE" ] && rm -f "$LOG_FILE"
    print_success "Log file cleaned"

    # Удалить PID файл
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"
    print_success "PID file cleaned"

    print_info "Cleanup completed"
}

daemon() {
    print_header "🏠 Home VPN Daemon starting..."

    # Сохранить PID
    echo $$ > "$PID_FILE"
    log_connection "DAEMON_STARTED PID=$(cat "$PID_FILE")"

    # Обработка сигналов
    # SIGTERM - нормальное завершение (systemctl stop)
    trap 'print_info "Received SIGTERM, shutting down gracefully..."; cleanup; exit 0' TERM

    # SIGINT - прерывание с клавиатуры (Ctrl+C)
    trap 'print_warning "Received SIGINT (Ctrl+C), interrupting..."; cleanup; exit 130' INT

    # SIGHUP - перезагрузка/переподключение (systemctl reload)
    trap 'print_info "Received SIGHUP, reconnecting..."; disconnect_vpn; sleep 2; connect_vpn' HUP

    local healthcheck_enabled
    healthcheck_enabled=$(get_healthcheck_config "enabled")

    if [ "$healthcheck_enabled" = "true" ]; then
        local healthcheck_interval
        healthcheck_interval=$(get_healthcheck_config "interval")
    fi

    while true; do
        local status
        status=$(get_vpn_status)

        case "$status" in
            "not_configured"|"disconnected"|"failed")
                print_info "VPN not connected, attempting connection..."
                connect_vpn || true
                ;;
            "connected")
                print_info "VPN connected, monitoring..."

                # Health check - проверить что туннель действительно работает
                if [ "$healthcheck_enabled" = "true" ]; then
                    local vpn_ip
                    vpn_ip=$(nmcli -t -f IP4.ADDRESS connection show "$(get_vpn_connection_name)" 2>/dev/null | cut -d: -f2 | head -1)

                    if [ -z "$vpn_ip" ]; then
                        print_warning "VPN reports connected but no IP assigned, reconnecting..."
                        disconnect_vpn
                        sleep 2
                        connect_vpn
                    fi
                fi
                ;;
            "connecting")
                print_info "VPN connecting, waiting..."
                ;;
        esac

        if [ "$healthcheck_enabled" = "true" ]; then
            sleep $healthcheck_interval
        else
            return 0
        fi
    done
}

# Показать статус
show_status() {
    print_header "🔍 Home VPN Status:"

    case $(get_vpn_status) in
        "connected")
            print_success "VPN Status: CONNECTED to $(get_vpn_config "server")"

            # Показать детали подключения
            local vpn_ip vpn_gw dns
            vpn_ip=$(nmcli -t -f IP4.ADDRESS connection show "$(get_vpn_connection_name)" 2>/dev/null | cut -d: -f2 | head -1)
            vpn_gw=$(nmcli -t -f IP4.GATEWAY connection show "$(get_vpn_connection_name)" 2>/dev/null | cut -d: -f2)
            dns=$(nmcli -t -f IP4.DNS connection show "$(get_vpn_connection_name)" 2>/dev/null | cut -d: -f2 | head -1)

            [ -n "$vpn_ip" ] && print_info "  VPN IP: $vpn_ip"
            [ -n "$vpn_gw" ] && print_info "  Gateway: $vpn_gw"
            [ -n "$dns" ] && print_info "  DNS: $dns"

            # Показать время подключения
            if [ -f "$LOG_FILE" ]; then
                local last_connect
                last_connect=$(grep "CONNECTED" "$LOG_FILE" | tail -1 | cut -d' ' -f1-2 | tr -d '[]')
                [ -n "$last_connect" ] && print_info "  Connected since: $last_connect"
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

    # Daemon статус
    echo ""
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        print_success "Daemon: RUNNING (PID: $(cat "$PID_FILE"))"
    else
        print_info "Daemon: NOT RUNNING"
    fi

    # Healthcheck настройки
    echo ""
    print_header "🏥 Healthcheck Configuration:"
    local healthcheck_enabled
    healthcheck_enabled=$(get_healthcheck_config "enabled")

    if [ "$healthcheck_enabled" = "true" ]; then
        print_success "Healthcheck: ENABLED"
        local healthcheck_interval
        healthcheck_interval=$(get_healthcheck_config "interval")
        print_info "  Check interval: ${healthcheck_interval}s"
    else
        print_warning "Healthcheck: DISABLED"
    fi
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Обработка команд
main() {
    local command="${1:-}"

    case "$command" in
        daemon)
            daemon
        ;;
        connect)
            connect_vpn
            ;;
        disconnect)
            disconnect_vpn
            ;;
        reconnect)
            print_header "🔄 Reconnecting to VPN..."
            disconnect_vpn
            sleep 2
            connect_vpn
            ;;
        status)
            show_status
            ;;
        logs)
            print_header "📋 Home VPN Logs:"
            if [ -f "$LOG_FILE" ]; then
                print_info "Connection history:"
                tail -20 "$LOG_FILE"
                echo ""
            fi
            print_info "Systemd service logs:"
            journalctl --user -u homevpnctl -f --no-pager
            ;;
        config)
            print_header "🔧 Home VPN Configuration:"
            print_info "Config file: $CONFIG_FILE"
            print_info "Example file: $CONFIG_DIR/config.example.json"

            if [ -f "$CONFIG_FILE" ]; then
                echo ""
                print_info "Connection name: $(get_vpn_connection_name)"

                echo ""
                print_info "Current configuration:"
                print_status "  Server: $(get_vpn_config "server")"
                print_status "  Login: $(get_vpn_config "login")"

                if [ "$(get_vpn_config "password")" != "null" ]; then
                    print_status "  Password: [configured]"
                else
                    print_status "  Password: [not configured]"
                fi

                if [ "$(get_vpn_config "psk")" != "null" ]; then
                    print_status "  PSK: [configured]"
                else
                    print_status "  PSK: [not configured]"
                fi

                # Healthcheck настройки
                echo ""
                print_info "Healthcheck settings:"
                print_status "  Enabled: $(get_healthcheck_config "enabled")"
                print_status "  Interval: $(get_healthcheck_config "interval")s"
            else
                print_warning "Config file not found: $CONFIG_FILE"
            fi
            ;;
        recreate)
            print_header "🔧 Recreating VPN connection..."
            create_vpn_connection
            ;;
        service-enable)
            systemctl --user enable homevpnctl
            print_success "Home VPN service enabled for autostart"
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
        service-disable)
            systemctl --user disable homevpnctl
            print_success "Home VPN service disabled from autostart"
            ;;
        clean)
            cleanup
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
    echo -e "  ${GREEN}connect${NC}                Connect to Home VPN"
    echo -e "  ${RED}disconnect${NC}             Disconnect from Home VPN"
    echo -e "  ${CYAN}reconnect${NC}              Reconnect to Home VPN"
    echo ""

    print_status "⚙️ VPN management:"
    echo -e "  ${BLUE}status${NC}                 Show VPN connection status"
    echo -e "  ${CYAN}logs${NC}                   Show connection logs"
    echo -e "  ${YELLOW}recreate${NC}               Recreate NetworkManager connection"
    echo -e "  ${RED}clean${NC}                  Clean up all VPN configuration"
    echo ""

    print_status "🔧 Service management:"
    echo -e "  ${GREEN}service-enable${NC}         Enable autostart"
    echo -e "  ${GREEN}service-start${NC}          Start systemd service"
    echo -e "  ${RED}service-stop${NC}           Stop systemd service"
    echo -e "  ${CYAN}service-restart${NC}        Restart systemd service"
    echo -e "  ${RED}service-disable${NC}        Disable autostart"
    echo ""

    print_status "📋 Configuration:"
    echo -e "  ${PURPLE}config${NC}                 Show config file paths and settings"
    echo ""

    print_status "💡 Example usage:"
    echo -e "  homevpnctl connect     # Connect to VPN"
    echo -e "  homevpnctl status      # Check connection status"
    echo -e "  homevpnctl logs        # View connection logs"
    echo -e "  homevpnctl disconnect  # Disconnect from VPN"
    echo ""

    print_info "Configuration file: $CONFIG_FILE"
    print_info "Required format:"
    print_info "  {"
    print_info "    \"name\": \"Connection-Name\","
    print_info "    \"vpn\": {"
    print_info "      \"server\": \"vpn.example.com\","
    print_info "      \"login\": \"user\","
    print_info "      \"password\": \"pass\","
    print_info "      \"psk\": \"key\""
    print_info "    },"
    print_info "    \"healthcheck\": {"
    print_info "      \"enabled\": true,"
    print_info "      \"interval\": 30,"
    print_info "    }"
    print_info "  }"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"