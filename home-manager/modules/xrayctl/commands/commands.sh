#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly CONFIG_DIR="@homeDirectory@/.config/xray"
readonly PROXY_ENV_FILE="$CONFIG_DIR/proxy-env"
readonly PROXY_ENV_FISH_FILE="$CONFIG_DIR/proxy-env.fish"
readonly PROXY_ENABLED_FILE="$CONFIG_DIR/.proxy-enabled"

# Настройки прокси по умолчанию
readonly DEFAULT_HOST="127.0.0.1"
readonly DEFAULT_SOCKS_PORT="10808"
readonly DEFAULT_HTTP_PORT="10809"
readonly NO_PROXY_LIST="localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"

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
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if ! command -v gsettings >/dev/null 2>&1; then
        missing_deps+=("gsettings")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
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
    if [ ! -f "@configFile@" ]; then
        local example_file="@homeDirectory@/.config/xray/config/config.example.json"
        
        if [ ! -f "$example_file" ]; then
            print_error "Example config file not found: $example_file"
            exit 1
        fi
        
        print_info "Creating default config from example..."
        cp "$example_file" "@configFile@"
        print_success "Config created at: @configFile@"
    fi
}

# Получить настройки прокси из config.json
get_proxy_config() {
    local protocol="$1"
    local field="$2"  # "host" или "port"
    
    if [ ! -f "@configFile@" ]; then
        return 1
    fi
    
    local query=".inbounds[]? | select(.protocol == \"$protocol\")"
    if [ "$field" = "host" ]; then
        query="$query | .listen // \"$DEFAULT_HOST\""
    else
        query="$query | .port"
    fi
    
    jq -r "$query" "@configFile@" 2>/dev/null | head -1
}

# Получить адрес прокси для протокола
get_proxy_address() {
    local protocol="$1"
    local host port default_port
    
    case "$protocol" in
        "http")
            default_port="$DEFAULT_HTTP_PORT"
            ;;
        "socks")
            default_port="$DEFAULT_SOCKS_PORT"
            ;;
        *)
            print_error "Unsupported protocol: $protocol"
            return 1
            ;;
    esac
    
    host=$(get_proxy_config "$protocol" "host")
    port=$(get_proxy_config "$protocol" "port")
    
    # Fallback значения
    if [ -z "$host" ] || [ "$host" = "null" ]; then
        host="$DEFAULT_HOST"
    fi
    
    if [ -z "$port" ] || [ "$port" = "null" ]; then
        port="$default_port"
    fi
    
    printf '%s:%s' "$host" "$port"
}

# Проверить доступность протокола в конфигурации
has_protocol() {
    local protocol="$1"
    
    if [ ! -f "@configFile@" ]; then
        return 1
    fi
    
    local result
    result=$(get_proxy_config "$protocol" "port")
    [ -n "$result" ] && [ "$result" != "null" ]
}

# Получить предпочтительный протокол для системы (SOCKS имеет приоритет)
get_system_proxy_protocol() {
    if has_protocol "socks"; then
        echo "socks"
    elif has_protocol "http"; then
        echo "http"
    else
        echo "socks"  # fallback
    fi
}

# Получить предпочтительный протокол для терминала (HTTP имеет приоритет для совместимости)
get_terminal_proxy_protocol() {
    if has_protocol "http"; then
        echo "http"
    elif has_protocol "socks"; then
        echo "socks"
    else
        echo "http"  # fallback
    fi
}

# =============================================================================
# УПРАВЛЕНИЕ СИСТЕМНЫМ ПРОКСИ (GNOME)
# =============================================================================

# Включить системный прокси GNOME
enable_system_proxy() {
    local proxy_addr="$1"
    local protocol="$2"
    local host port
    
    host=$(echo "$proxy_addr" | cut -d: -f1)
    port=$(echo "$proxy_addr" | cut -d: -f2)
    
    gsettings set org.gnome.system.proxy mode 'manual'
    
    case "$protocol" in
        "socks")
            gsettings set org.gnome.system.proxy.socks host "$host"
            gsettings set org.gnome.system.proxy.socks port "$port"
            print_success "GNOME system proxy enabled (SOCKS $host:$port)"
            ;;
        "http")
            gsettings set org.gnome.system.proxy.http host "$host"
            gsettings set org.gnome.system.proxy.http port "$port"
            gsettings set org.gnome.system.proxy.https host "$host"
            gsettings set org.gnome.system.proxy.https port "$port"
            print_success "GNOME system proxy enabled (HTTP $host:$port)"
            ;;
        *)
            print_error "Unsupported protocol for system proxy: $protocol"
            return 1
            ;;
    esac
}

# Отключить системный прокси GNOME
disable_system_proxy() {
    gsettings set org.gnome.system.proxy mode 'none'
    print_success "GNOME system proxy disabled"
}

# =============================================================================
# УПРАВЛЕНИЕ ТЕРМИНАЛЬНЫМ ПРОКСИ
# =============================================================================

# Создать файлы с переменными окружения прокси
create_proxy_env_files() {
    local proxy_addr="$1"
    local protocol="$2"
    local proxy_url="$protocol://$proxy_addr"
    
    mkdir -p "$CONFIG_DIR"
    
    # Bash/Zsh версия
    cat > "$PROXY_ENV_FILE" <<EOF
# Xray proxy environment variables (managed by xrayctl)
export http_proxy=$proxy_url
export https_proxy=$proxy_url
export ftp_proxy=$proxy_url
export HTTP_PROXY=$proxy_url
export HTTPS_PROXY=$proxy_url
export FTP_PROXY=$proxy_url
export no_proxy=$NO_PROXY_LIST
export NO_PROXY=$NO_PROXY_LIST
EOF
    
    # Fish версия
    cat > "$PROXY_ENV_FISH_FILE" <<FISH_VARS
# Xray proxy environment variables (managed by xrayctl)
set -x http_proxy $proxy_url
set -x https_proxy $proxy_url
set -x ftp_proxy $proxy_url
set -x HTTP_PROXY $proxy_url
set -x HTTPS_PROXY $proxy_url
set -x FTP_PROXY $proxy_url
set -x no_proxy $NO_PROXY_LIST
set -x NO_PROXY $NO_PROXY_LIST
FISH_VARS
}

# Определить тип shell и информацию о профиле
get_shell_info() {
    if command -v fish >/dev/null 2>&1; then
        echo "fish @homeDirectory@/.config/fish/conf.d/xray-proxy.fish"
    elif [ -f "@homeDirectory@/.zshrc" ]; then
        echo "zsh @homeDirectory@/.zshrc"
    elif [ -f "@homeDirectory@/.bashrc" ]; then
        echo "bash @homeDirectory@/.bashrc"
    else
        echo "bash @homeDirectory@/.bashrc"  # fallback
    fi
}

# Парсить информацию о shell
parse_shell_info() {
    local shell_info="$1"
    local field="$2"  # "type" или "profile"
    
    case "$field" in
        "type")
            echo "$shell_info" | cut -d' ' -f1
            ;;
        "profile")
            echo "$shell_info" | cut -d' ' -f2
            ;;
        *)
            print_error "Invalid field: $field"
            return 1
            ;;
    esac
}

# Настроить shell профиль для автозагрузки прокси
setup_shell_profile() {
    local shell_info shell_type profile_path
    
    shell_info=$(get_shell_info)
    shell_type=$(parse_shell_info "$shell_info" "type")
    profile_path=$(parse_shell_info "$shell_info" "profile")
    
    case "$shell_type" in
        "fish")
            setup_fish_profile "$profile_path"
            ;;
        "bash"|"zsh")
            setup_bash_profile "$profile_path"
            ;;
        *)
            print_error "Unsupported shell type: $shell_type"
            return 1
            ;;
    esac
    
    echo "$shell_type"
}

# Настроить профиль Fish
setup_fish_profile() {
    local profile_path="$1"
    
    mkdir -p "$(dirname "$profile_path")"
    if [ ! -f "$profile_path" ]; then
        cat > "$profile_path" <<FISH_EOF
# Xray proxy environment (managed by xrayctl)
if test -f $PROXY_ENV_FISH_FILE; and test -f $PROXY_ENABLED_FILE
    source $PROXY_ENV_FISH_FILE
end
FISH_EOF
        print_success "Created Fish proxy config: $profile_path"
    else
        print_info "Fish proxy config already exists: $profile_path"
    fi
}

# Настроить профиль Bash/Zsh
setup_bash_profile() {
    local profile_path="$1"
    
    if ! grep -q "xray/proxy-env" "$profile_path" 2>/dev/null; then
        {
            echo ""
            echo "# Xray proxy environment (managed by xrayctl)"
            echo "if [ -f $PROXY_ENV_FILE ] && [ -f $PROXY_ENABLED_FILE ]; then"
            echo "  source $PROXY_ENV_FILE"
            echo "fi"
        } >> "$profile_path"
        print_success "Added proxy config to $profile_path"
    fi
}

# Включить терминальный прокси
enable_terminal_proxy() {
    local proxy_addr="$1"
    local protocol="$2"
    local shell_type
    
    create_proxy_env_files "$proxy_addr" "$protocol"
    shell_type=$(setup_shell_profile)
    touch "$PROXY_ENABLED_FILE"
    
    print_success "Terminal proxy enabled ($protocol://$proxy_addr)"
    echo ""
    print_warning "To use proxy in current session, run:"
    
    case "$shell_type" in
        "fish")
            print_status "source $PROXY_ENV_FISH_FILE"
            print_info "Or restart terminal (Fish will auto-load on new sessions)"
            ;;
        *)
            print_status "source $PROXY_ENV_FILE"
            print_info "Or restart terminal (will auto-load on new sessions)"
            ;;
    esac
}

# Очистить переменные окружения прокси
clear_proxy_env() {
    unset http_proxy https_proxy ftp_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY
}

# Удалить настройки прокси из shell профиля
cleanup_shell_profile() {
    local shell_info shell_type profile_path
    
    shell_info=$(get_shell_info)
    shell_type=$(parse_shell_info "$shell_info" "type")
    profile_path=$(parse_shell_info "$shell_info" "profile")
    
    case "$shell_type" in
        "fish")
            rm -f "@homeDirectory@/.config/fish/conf.d/xray-proxy.fish"
            ;;
        *)
            if [ -f "$profile_path" ]; then
                sed -i '/# Xray proxy environment (managed by xrayctl)/,/^fi$/d' "$profile_path"
            fi
            ;;
    esac
}

# Отключить терминальный прокси
disable_terminal_proxy() {
    # Удалить все файлы и настройки
    rm -f "$PROXY_ENABLED_FILE" "$PROXY_ENV_FILE" "$PROXY_ENV_FISH_FILE"
    
    # Очистить переменные в текущей сессии
    clear_proxy_env
    
    # Очистить shell профили
    cleanup_shell_profile
    
    print_success "Terminal proxy disabled"
    print_info "Environment variables cleared in current session"
    print_info "Restart terminal to fully apply changes"
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Обработка команд
main() {
    local command="${1:-}"
    
    case "$command" in
        start)
            ensure_config
            systemctl --user start xray
            print_success "Xray service started"
            ;;
        stop)
            systemctl --user stop xray
            print_success "Xray service stopped"
            ;;
        restart)
            ensure_config
            systemctl --user restart xray
            print_success "Xray service restarted"
            ;;
        status)
            print_header "Xray Service Status:"
            systemctl --user status xray
            ;;
        logs)
            print_header "Xray Service Logs:"
            journalctl --user -u xray -f
            ;;
        enable)
            ensure_config
            systemctl --user enable xray
            print_success "Xray service enabled for autostart"
            ;;
        disable)
            systemctl --user disable xray
            print_success "Xray service disabled from autostart"
            ;;
        config)
            ensure_config
            print_header "Xray Configuration:"
            print_info "Config file: @configFile@"
            print_info "Example file: @homeDirectory@/.config/xray/config.example.json"
            ;;
        proxy-on)
            ensure_config
            local protocol proxy_addr
            protocol=$(get_system_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")
            
            enable_system_proxy "$proxy_addr" "$protocol"
            print_info "Browser and most apps will now use proxy"
            ;;
        proxy-off)
            disable_system_proxy
            ;;
        proxy-status)
            print_header "System Proxy Status:"
            local mode host port
            mode=$(gsettings get org.gnome.system.proxy mode)
            if [ "$mode" = "'manual'" ]; then
                host=$(gsettings get org.gnome.system.proxy.socks host)
                port=$(gsettings get org.gnome.system.proxy.socks port)
                print_success "System proxy: ENABLED ($host:$port)"
            else
                print_status "System proxy: DISABLED"
            fi
            ;;
        terminal-proxy-on)
            ensure_config
            local protocol proxy_addr
            protocol=$(get_terminal_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")
            
            enable_terminal_proxy "$proxy_addr" "$protocol"
            ;;
        terminal-proxy-off)
            disable_terminal_proxy
            ;;
        terminal-proxy-status)
            print_header "Terminal Proxy Status:"
            if [ -f "$PROXY_ENABLED_FILE" ]; then
                print_success "Terminal proxy: ENABLED"
                if [ -n "${http_proxy:-}" ]; then
                    print_success "Current session: ACTIVE ($http_proxy)"
                else
                    print_warning "Current session: INACTIVE (restart terminal)"
                fi
            else
                print_status "Terminal proxy: DISABLED"
            fi
            ;;
        env-proxy)
            ensure_config
            local protocol proxy_addr
            protocol=$(get_terminal_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")
            
            print_header "Manual Proxy Environment Variables:"
            echo "export http_proxy=$protocol://$proxy_addr"
            echo "export https_proxy=$protocol://$proxy_addr"  
            echo "export ftp_proxy=$protocol://$proxy_addr"
            echo "export no_proxy=$NO_PROXY_LIST"
            echo ""
            print_info "To apply in current shell:"
            print_status 'eval "$(xrayctl env-proxy | grep export)"'
            ;;
        all-on)
            print_header "🚀 Starting Xray and enabling all proxy settings..."
            echo ""
            
            # Запустить и включить xray сервис
            ensure_config
            systemctl --user start xray
            systemctl --user enable xray
            print_success "Xray service started and enabled"
            
            # Получить настройки прокси для системы
            local system_protocol system_proxy_addr
            system_protocol=$(get_system_proxy_protocol)
            system_proxy_addr=$(get_proxy_address "$system_protocol")
            
            # Получить настройки прокси для терминала
            local terminal_protocol terminal_proxy_addr
            terminal_protocol=$(get_terminal_proxy_protocol)
            terminal_proxy_addr=$(get_proxy_address "$terminal_protocol")
            
            # Включить прокси
            enable_system_proxy "$system_proxy_addr" "$system_protocol"
            enable_terminal_proxy "$terminal_proxy_addr" "$terminal_protocol"
            
            echo ""
            print_header "🎉 All proxy settings enabled!"
            print_status "   • Xray service: ${GREEN}RUNNING${NC}"
            print_status "   • System proxy (GNOME): ${GREEN}ENABLED${NC}"
            print_status "   • Terminal proxy: ${GREEN}ENABLED${NC}"
            ;;
        all-off)
            print_header "🔒 Disabling all proxy settings..."
            echo ""
            
            # Остановить xray сервис
            systemctl --user stop xray
            print_success "Xray service stopped"
            
            # Выключить системный и терминальный прокси
            disable_system_proxy
            disable_terminal_proxy
            
            echo ""
            print_header "🔒 All proxy settings disabled!"
            print_status "   • Xray service: ${RED}STOPPED${NC}"
            print_status "   • System proxy (GNOME): ${RED}DISABLED${NC}"
            print_status "   • Terminal proxy: ${RED}DISABLED${NC}"
            echo ""
            print_info "Restart terminal to apply terminal proxy changes"
            ;;
        clear-env)
            print_header "🧹 Clearing proxy environment variables..."
            clear_proxy_env
            print_success "Proxy environment variables cleared"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# Показать справку
show_help() {
    print_header "🔧 Xray User Management Tool"
    echo ""
    print_info "Usage: xrayctl {command}"
    echo ""
    
    print_status "🚀 Quick commands:"
    echo -e "  ${GREEN}all-on${NC}                 Start Xray + enable all proxy settings"
    echo -e "  ${RED}all-off${NC}                Stop Xray + disable all proxy settings"
    echo ""
    
    print_status "⚙️  Service management:"
    echo -e "  ${CYAN}start${NC}                  Start Xray service"
    echo -e "  ${CYAN}stop${NC}                   Stop Xray service"
    echo -e "  ${CYAN}restart${NC}                Restart Xray service"
    echo -e "  ${CYAN}status${NC}                 Show service status"
    echo -e "  ${CYAN}logs${NC}                   Show service logs"
    echo -e "  ${CYAN}enable${NC}                 Enable autostart"
    echo -e "  ${CYAN}disable${NC}                Disable autostart"
    echo ""

    print_status "🌐 System proxy (GNOME):"
    echo -e "  ${GREEN}proxy-on${NC}               Enable system-wide proxy"
    echo -e "  ${RED}proxy-off${NC}              Disable system-wide proxy"
    echo -e "  ${BLUE}proxy-status${NC}           Show system proxy status"
    echo ""
    
    print_status "💻 Terminal proxy:"
    echo -e "  ${GREEN}terminal-proxy-on${NC}      Enable terminal proxy (persistent)"
    echo -e "  ${RED}terminal-proxy-off${NC}     Disable terminal proxy"
    echo -e "  ${BLUE}terminal-proxy-status${NC}  Show terminal proxy status"
    echo -e "  ${YELLOW}env-proxy${NC}              Show manual environment variables"
    echo -e "  ${YELLOW}clear-env${NC}              Clear proxy environment variables"
    echo ""
    
    print_status "📋 Configuration:"
    echo -e "  ${PURPLE}config${NC}                 Show config file paths"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"