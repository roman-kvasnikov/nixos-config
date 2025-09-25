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

    if ! command -v arp >/dev/null 2>&1; then
        missing_deps+=("arp")
    fi

    if ! command -v ping >/dev/null 2>&1; then
        missing_deps+=("ping")
    fi

    if ! command -v ip >/dev/null 2>&1; then
        missing_deps+=("ip")
    fi

    if ! command -v systemctl >/dev/null 2>&1; then
        missing_deps+=("systemctl")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure nmcli, jq, arp, ping, ip, systemctl are installed"
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
    local field="$1"  # "connection.name", "connection.vpn.server", "connection.vpn.login", "connection.vpn.password", "connection.vpn.psk", "connection.ipv4.routes", "healthcheck.enabled", "network_detection.enabled", "network_detection.methods.gateway_check.enabled", "network_detection.methods.ping_check.enabled", "network_detection.methods.wifi_check.enabled", "network_detection.methods.mac_check.enabled"

    ensure_config

    # Используем jq для получения значения по пути (поддерживает точечную нотацию)
    jq -r ".$field // empty" "$CONFIG_FILE" 2>/dev/null
}

# Получить настройки VPN соединения из конфигурации
get_connection_config() {
    local field="$1"  # "name", "vpn.server", "vpn.login", "vpn.password", "vpn.psk", "ipv4.routes"
    local value

    value=$(get_config_value "connection.$field")

    case "$field" in
        "name"|"vpn.server"|"vpn.login"|"vpn.password"|"vpn.psk")
            # Валидация обязательных строковых значений
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                echo "$value"
            else
                print_error "Connection field "$field" is not configured"
                exit 1
            fi
            ;;
        "ipv4.routes")
            # Валидация массива строковых значений
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                # Проверяем, что это не пустой массив
                local array_length=$(echo "$value" | jq 'length' 2>/dev/null)
                if [ "$array_length" -gt 0 ]; then
                    echo "$value" | jq -r '.[]?' 2>/dev/null | tr '\n' ' '
                else
                    echo ""
                fi
            else
                echo ""
            fi
            ;;
        *)
            print_error "Invalid VPN connection config field: $field"
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
    local name vpn_server vpn_login vpn_password vpn_psk ipv4_routes

    name=$(get_connection_config "name")

    vpn_server=$(get_connection_config "vpn.server")
    vpn_login=$(get_connection_config "vpn.login")
    vpn_password=$(get_connection_config "vpn.password")
    vpn_psk=$(get_connection_config "vpn.psk")

    ipv4_routes=$(get_connection_config "ipv4.routes")

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
        vpn.data "gateway=$vpn_server, user=$vpn_login, password-flags=0, ipsec-enabled=yes, ipsec-psk=$vpn_psk, ipsec-pfs=no" \
        vpn.secrets "password=$vpn_password" \
        >/dev/null 2>&1

    if [ -n "$ipv4_routes" ] && [ "$ipv4_routes" != "null" ]; then
        nmcli connection modify "$name" ipv4.routes "$ipv4_routes" >/dev/null 2>&1
    fi

    print_success "VPN connection created successfully"
}

# =============================================================================
# ОПРЕДЕЛЕНИЕ ДОМАШНЕЙ СЕТИ
# =============================================================================

# Проверить, включено ли определение сети
is_network_detection_enabled() {
    [ "$(get_config_value "network_detection.enabled")" = "true" ]
}

# Проверить по шлюзу
check_home_gateway() {
    if [ "$(get_config_value "network_detection.methods.gateway_check.enabled")" != "true" ]; then
        return 1
    fi
    
    local current_gateway home_gateways
    
    current_gateway=$(ip route | grep '^default' | awk '{print $3}' | head -1)
    
    if [ -z "$current_gateway" ]; then
        return 1
    fi
    
    # Получаем список домашних шлюзов из конфигурации
    home_gateways=$(get_config_value "network_detection.methods.gateway_check.home_gateways" | jq -r '.[]?' 2>/dev/null)
    
    while IFS= read -r gateway; do
        if [ -n "$gateway" ] && [ "$current_gateway" = "$gateway" ]; then
            return 0
        fi
    done <<< "$home_gateways"
    
    return 1
}

# Проверить доступность домашних хостов
check_home_hosts() {
    if [ "$(get_config_value "network_detection.methods.ping_check.enabled")" != "true" ]; then
        return 1
    fi
    
    local home_hosts
    home_hosts=$(get_config_value "network_detection.methods.ping_check.home_hosts" | jq -r '.[]?' 2>/dev/null)
    
    while IFS= read -r host; do
        if [ -n "$host" ]; then
            if ping -c1 -W2 "$host" >/dev/null 2>&1; then
                return 0
            fi
        fi
    done <<< "$home_hosts"
    
    return 1
}

# Проверить WiFi SSID
check_home_wifi() {
    if [ "$(get_config_value "network_detection.methods.wifi_check.enabled")" != "true" ]; then
        return 1
    fi
    
    local current_ssid home_ssids
    
    current_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -1)
    
    if [ -z "$current_ssid" ]; then
        return 1
    fi
    
    home_ssids=$(get_config_value "network_detection.methods.wifi_check.home_ssids" | jq -r '.[]?' 2>/dev/null)
    
    while IFS= read -r ssid; do
        if [ -n "$ssid" ] && [ "$current_ssid" = "$ssid" ]; then
            return 0
        fi
    done <<< "$home_ssids"
    
    return 1
}

# Проверить MAC адрес роутера
check_home_router_mac() {
    if [ "$(get_config_value "network_detection.methods.mac_check.enabled")" != "true" ]; then
        return 1
    fi
    
    local current_gateway router_mac home_macs

    current_gateway=$(ip route | grep '^default' | awk '{print $3}' | head -1)
    
    if [ -z "$current_gateway" ]; then
        return 1
    fi
    
    # Попытаться получить MAC адрес шлюза
    router_mac=$(arp -n "$current_gateway" 2>/dev/null | awk 'NR==2{print $3}')
    
    if [ -z "$router_mac" ]; then
        # Попробовать пингануть шлюз чтобы он появился в ARP таблице
        ping -c1 -W1 "$current_gateway" >/dev/null 2>&1
        router_mac=$(arp -n "$current_gateway" 2>/dev/null | awk 'NR==2{print $3}')
    fi
    
    if [ -z "$router_mac" ]; then
        return 1
    fi
    
    home_macs=$(get_config_value "network_detection.methods.mac_check.home_router_macs" | jq -r '.[]?' 2>/dev/null)
    
    while IFS= read -r mac; do
        if [ -n "$mac" ] && [ "$router_mac" = "$mac" ]; then
            return 0
        fi
    done <<< "$home_macs"
    
    return 1
}

# Главная функция определения домашней сети
is_at_home() {
    if ! is_network_detection_enabled; then
        # Если определение отключено, всегда считаем что не дома
        return 1
    fi
    
    # Проверяем каждый включенный метод - ВСЕ должны пройти
    # Если хотя бы один включенный метод не прошел - мы НЕ дома
    
    if [ "$(get_config_value "network_detection.methods.gateway_check.enabled")" = "true" ]; then
        if ! check_home_gateway; then
            return 1
        fi
    fi
    
    if [ "$(get_config_value "network_detection.methods.ping_check.enabled")" = "true" ]; then
        if ! check_home_hosts; then
            return 1
        fi
    fi
    
    if [ "$(get_config_value "network_detection.methods.wifi_check.enabled")" = "true" ]; then
        if ! check_home_wifi; then
            return 1
        fi
    fi
    
    if [ "$(get_config_value "network_detection.methods.mac_check.enabled")" = "true" ]; then
        if ! check_home_router_mac; then
            return 1
        fi
    fi
    
    # Если дошли сюда - все включенные методы прошли проверку
    return 0
}

# =============================================================================
# УПРАВЛЕНИЕ VPN СОЕДИНЕНИЕМ
# =============================================================================

# Проверить статус VPN соединения
get_vpn_status() {
    local connection_state

    if ! nmcli connection show "$(get_connection_config "name")" >/dev/null 2>&1; then
        echo "not_configured"
        return
    fi

    connection_state=$(nmcli -t -f GENERAL.STATE connection show "$(get_connection_config "name")" 2>/dev/null | cut -d: -f2)

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

# Подключиться к VPN (с проверкой домашней сети)
connect_vpn() {
    # Проверить, находимся ли мы уже в домашней сети
    if is_at_home; then
        print_warning "Already at home network, VPN connection not needed"
        log_connection "SKIPPED_HOME"
        return 0
    fi
    
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

    print_info "Connecting to VPN: $(get_connection_config "name")"

    if nmcli connection up "$(get_connection_config "name")" >/dev/null 2>&1; then
        log_connection "CONNECTED"
        print_success "VPN connected successfully"

        # Показать информацию о подключении
        print_info "Connected to server: $(get_connection_config "vpn.server")"
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

    print_info "Disconnecting from VPN: $(get_connection_config "name")"

    if nmcli connection down "$(get_connection_config "name")" >/dev/null 2>&1; then
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
    if nmcli connection show "$(get_connection_config "name")" >/dev/null 2>&1; then
        nmcli connection delete "$(get_connection_config "name")" >/dev/null 2>&1
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

    # Проверить сразу при старте - если дома, завершиться
    if is_at_home; then
        print_info "Already at home network during startup, daemon not needed"
        log_connection "DAEMON_STOPPED_HOME"
        rm -f "$PID_FILE"
        exit 0
    fi

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

    # Попробовать подключиться один раз при старте 
    # (connect_vpn уже проверяет дома ли мы, но мы уже проверили выше)
    print_info "Initial connection attempt..."
    connect_vpn || true

    while true; do
        local status
        status=$(get_vpn_status)

        case "$status" in
            "not_configured"|"disconnected"|"failed")
                print_info "VPN not connected, attempting reconnection..."
                # НЕ проверяем дома ли мы - если соединение упало, 
                # значит мы уехали из дома и нужно переподключиться
                if nmcli connection up "$(get_connection_config "name")" >/dev/null 2>&1; then
                    log_connection "RECONNECTED"
                    print_success "VPN reconnected successfully"
                else
                    log_connection "RECONNECTION_FAILED"
                    print_error "Failed to reconnect to VPN"
                fi
                ;;
            "connected")
                print_info "VPN connected, monitoring..."

                # Health check - проверить что туннель действительно работает
                if [ "$healthcheck_enabled" = "true" ]; then
                    local vpn_ip
                    vpn_ip=$(nmcli -t -f IP4.ADDRESS connection show "$(get_connection_config "name")" 2>/dev/null | cut -d: -f2 | head -1)

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
            print_success "VPN Status: CONNECTED to $(get_connection_config "vpn.server")"

            # Показать детали подключения
            local vpn_ip vpn_gw dns
            vpn_ip=$(nmcli -t -f IP4.ADDRESS connection show "$(get_connection_config "name")" 2>/dev/null | cut -d: -f2 | head -1)
            vpn_gw=$(nmcli -t -f IP4.GATEWAY connection show "$(get_connection_config "name")" 2>/dev/null | cut -d: -f2)
            dns=$(nmcli -t -f IP4.DNS connection show "$(get_connection_config "name")" 2>/dev/null | cut -d: -f2 | head -1)

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
                print_info "Connection name: $(get_connection_config "name")"

                echo ""
                print_info "Current configuration:"
                print_status "  Server: $(get_connection_config "vpn.server")"
                print_status "  Login: $(get_connection_config "vpn.login")"

                if [ "$(get_connection_config "vpn.password")" != "null" ]; then
                    print_status "  Password: [configured]"
                else
                    print_status "  Password: [not configured]"
                fi

                if [ "$(get_connection_config "vpn.psk")" != "null" ]; then
                    print_status "  PSK: [configured]"
                else
                    print_status "  PSK: [not configured]"
                fi

                # Healthcheck настройки
                echo ""
                print_info "Healthcheck settings:"
                print_status "  Enabled: $(get_healthcheck_config "enabled")"
                print_status "  Interval: $(get_healthcheck_config "interval")s"
                
                # Network detection настройки
                echo ""
                print_info "Network detection settings:"
                if is_network_detection_enabled; then
                    print_status "  Enabled: true"
                    
                    if [ "$(get_config_value "network_detection.methods.gateway_check.enabled")" = "true" ]; then
                        print_status "  Gateway check: enabled"
                        local gateways
                        gateways=$(get_config_value "network_detection.methods.gateway_check.home_gateways" | jq -r '.[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                        print_status "    Home gateways: $gateways"
                    fi
                    
                    if [ "$(get_config_value "network_detection.methods.ping_check.enabled")" = "true" ]; then
                        print_status "  Ping check: enabled"
                        local hosts
                        hosts=$(get_config_value "network_detection.methods.ping_check.home_hosts" | jq -r '.[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                        print_status "    Home hosts: $hosts"
                    fi
                    
                    if [ "$(get_config_value "network_detection.methods.wifi_check.enabled")" = "true" ]; then
                        print_status "  WiFi check: enabled"
                        local ssids
                        ssids=$(get_config_value "network_detection.methods.wifi_check.home_ssids" | jq -r '.[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                        print_status "    Home SSIDs: $ssids"
                    fi
                    
                    if [ "$(get_config_value "network_detection.methods.mac_check.enabled")" = "true" ]; then
                        print_status "  MAC check: enabled"
                        local macs
                        macs=$(get_config_value "network_detection.methods.mac_check.home_router_macs" | jq -r '.[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                        print_status "    Router MACs: $macs"
                    fi
                else
                    print_status "  Enabled: false"
                fi
            else
                print_warning "Config file not found: $CONFIG_FILE"
            fi
            ;;
        recreate)
            print_header "🔧 Recreating VPN connection..."
            create_vpn_connection
            ;;
        check-home)
            print_header "🏠 Checking if at home network..."
            
            if is_at_home; then
                print_success "Currently at home network"
                
                # Показать какие методы сработали
                echo ""
                print_info "Detection methods results:"
                
                if check_home_gateway; then
                    local current_gateway
                    current_gateway=$(ip route | grep '^default' | awk '{print $3}' | head -1)
                    print_success "  Gateway check: MATCH ($current_gateway)"
                else
                    print_warning "  Gateway check: no match"
                fi
                
                if check_home_hosts; then
                    print_success "  Host ping check: MATCH"
                else
                    print_warning "  Host ping check: no match"
                fi
                
                if check_home_wifi; then
                    local current_ssid
                    current_ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -1)
                    print_success "  WiFi SSID check: MATCH ($current_ssid)"
                else
                    print_warning "  WiFi SSID check: no match"
                fi
                
                if check_home_router_mac; then
                    local current_gateway router_mac
                    current_gateway=$(ip route | grep '^default' | awk '{print $3}' | head -1)
                    router_mac=$(arp -n "$current_gateway" 2>/dev/null | awk 'NR==2{print $3}')
                    print_success "  Router MAC check: MATCH ($router_mac)"
                else
                    print_warning "  Router MAC check: no match"
                fi
                
                echo ""
                print_info "VPN connection will be skipped"
            else
                print_info "Not at home network"
                echo ""
                print_info "Detection methods results:"
                
                if ! is_network_detection_enabled; then
                    print_warning "  Network detection is disabled"
                else
                    print_warning "  Gateway check: no match"
                    print_warning "  Host ping check: no match"
                    print_warning "  WiFi SSID check: no match"
                    print_warning "  Router MAC check: no match"
                fi
                
                echo ""
                print_info "VPN connection will be attempted"
            fi
            ;;
        force-connect)
            print_header "⚡ Force connecting to VPN (bypassing home detection)..."
            
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

            print_info "Force connecting to VPN: $(get_connection_config "name")"

            if nmcli connection up "$(get_connection_config "name")" >/dev/null 2>&1; then
                log_connection "FORCE_CONNECTED"
                print_success "VPN force connected successfully"

                # Показать информацию о подключении
                print_info "Connected to server: $(get_connection_config "vpn.server")"
            else
                log_connection "FORCE_CONNECTION_FAILED"
                print_error "Failed to force connect to VPN"
                exit 1
            fi
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
    echo -e "  ${GREEN}connect${NC}                Connect to Home VPN (with home detection)"
    echo -e "  ${GREEN}force-connect${NC}          Force connect (bypass home detection)"
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

    print_status "🏠 Home network detection:"
    echo -e "  ${BLUE}check-home${NC}             Check if currently at home network"
    echo ""
    
    print_status "📋 Configuration:"
    echo -e "  ${PURPLE}config${NC}                 Show config file paths and settings"
    echo ""

    print_status "💡 Example usage:"
    echo -e "  homevpnctl connect       # Smart connect (checks if at home first)"
    echo -e "  homevpnctl check-home    # Check if currently at home"
    echo -e "  homevpnctl force-connect # Force connect bypassing home detection"
    echo -e "  homevpnctl status        # Check connection status"
    echo -e "  homevpnctl logs          # View connection logs"
    echo -e "  homevpnctl disconnect    # Disconnect from VPN"
    echo ""

    print_info "Configuration file: $CONFIG_FILE"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"