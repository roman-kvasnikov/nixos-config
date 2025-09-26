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
readonly PROXY_ENV_FILE="$CONFIG_DIR/proxy-env"
readonly PROXY_ENV_FISH_FILE="$CONFIG_DIR/proxy-env.fish"
readonly PROXY_ENABLED_FILE="$CONFIG_DIR/.proxy-enabled"

# Настройки прокси по умолчанию
readonly DEFAULT_HOST="127.0.0.1"
readonly DEFAULT_HTTP_PORT="10809"
readonly DEFAULT_SOCKS_PORT="10808"
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
# РАБОТА С КОНФИГУРАЦИЕЙ
# =============================================================================

# Получить настройки прокси из config.json
get_proxy_config() {
    local protocol="$1"
    local field="$2"  # "host" или "port"

    local query=".inbounds[]? | select(.protocol == \"$protocol\")"
    if [ "$field" = "host" ]; then
        query="$query | .listen // \"$DEFAULT_HOST\""
    else
        query="$query | .port"
    fi

    jq -r "$query" "$CONFIG_FILE" 2>/dev/null | head -1
}

# Получить адрес прокси для протокола
get_proxy_address() {
    local protocol="$1"

    local default_port

    case "$protocol" in
        "http")
            default_port="$DEFAULT_HTTP_PORT"
            ;;
        "socks")
            default_port="$DEFAULT_SOCKS_PORT"
            ;;
        *)
            print --error "Unsupported protocol: $protocol"
            exit 1
            ;;
    esac

    local host port

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

    local result=$(get_proxy_config "$protocol" "port")

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
            print --success "GNOME system proxy enabled (SOCKS $host:$port)"
            ;;
        "http")
            gsettings set org.gnome.system.proxy.http host "$host"
            gsettings set org.gnome.system.proxy.http port "$port"
            gsettings set org.gnome.system.proxy.https host "$host"
            gsettings set org.gnome.system.proxy.https port "$port"
            print --success "GNOME system proxy enabled (HTTP $host:$port)"
            ;;
        *)
            print --error "Unsupported protocol for system proxy: $protocol"
            exit 1
            ;;
    esac
}

# Отключить системный прокси GNOME
disable_system_proxy() {
    gsettings set org.gnome.system.proxy mode 'none'
    print --success "GNOME system proxy disabled"
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
        echo "fish $HOME/.config/fish/conf.d/xray-proxy.fish"
    elif [ -f "$HOME/.zshrc" ]; then
        echo "zsh $HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        echo "bash $HOME/.bashrc"
    else
        echo "bash $HOME/.bashrc"  # fallback
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
            print --error "Invalid field: $field"
            exit 1
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
            print --error "Unsupported shell type: $shell_type"
            exit 1
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
        print --success "Created Fish proxy config: $profile_path"
    else
        print --info "Fish proxy config already exists: $profile_path"
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
        print --success "Added proxy config to $profile_path"
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

    print --success "Terminal proxy enabled ($protocol://$proxy_addr)"
    echo ""
    print --warning "To use proxy in current session, run:"

    case "$shell_type" in
        "fish")
            print --cyan "source $PROXY_ENV_FISH_FILE"
            print --info "Or restart terminal (Fish will auto-load on new sessions)"
            ;;
        *)
            print --cyan "source $PROXY_ENV_FILE"
            print --info "Or restart terminal (will auto-load on new sessions)"
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
            rm -f "$HOME/.config/fish/conf.d/xray-proxy.fish"
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

    print --success "Terminal proxy disabled"
    print --info "Environment variables cleared in current session"
    print --info "Restart terminal to fully apply changes"
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Обработка команд
main() {
    local command="${1:-}"

    case "$command" in
        service-enable)
            systemctl --user enable xray
            print --success "Xray service enabled for autostart"
            ;;
        service-start)
            systemctl --user start xray
            print --success "Xray service started"
            ;;
        service-stop)
            systemctl --user stop xray
            print --success "Xray service stopped"
            ;;
        service-restart)
            systemctl --user restart xray
            print --success "Xray service restarted"
            ;;
        service-disable)
            systemctl --user disable xray
            print --success "Xray service disabled from autostart"
            ;;
        service-status)
            print --purple "Xray Service Status:"
            systemctl --user status xray
            ;;
        service-logs)
            print --purple "Xray Service Logs:"
            journalctl --user -u xray -f
            ;;
        config)
            print --purple "Xray Configuration:"
            print --info "Config file: $CONFIG_FILE"
            print --info "Example file: $CONFIG_DIR/config.example.json"
            ;;
        system-enable)
            local protocol proxy_addr
            protocol=$(get_system_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")

            enable_system_proxy "$proxy_addr" "$protocol" 2>/dev/null || true
            print --info "Browser and most apps will now use proxy"
            ;;
        system-disable)
            disable_system_proxy 2>/dev/null || true
            ;;
        system-status)
            print --purple "System Proxy Status:"
            local mode host port
            mode=$(gsettings get org.gnome.system.proxy mode)
            if [ "$mode" = "'manual'" ]; then
                host=$(gsettings get org.gnome.system.proxy.socks host)
                port=$(gsettings get org.gnome.system.proxy.socks port)
                print --success "System proxy: ENABLED ($host:$port)"
            else
                print --cyan "System proxy: DISABLED"
            fi
            ;;
        terminal-enable)
            local protocol proxy_addr
            protocol=$(get_terminal_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")

            enable_terminal_proxy "$proxy_addr" "$protocol"
            ;;
        terminal-disable)
            disable_terminal_proxy
            ;;
        terminal-status)
            print --purple "Terminal Proxy Status:"
            if [ -f "$PROXY_ENABLED_FILE" ]; then
                print --success "Terminal proxy: ENABLED"
                if [ -n "${http_proxy:-}" ]; then
                    print --success "Current session: ACTIVE ($http_proxy)"
                else
                    print --warning "Current session: INACTIVE (restart terminal)"
                fi
            else
                print --cyan "Terminal proxy: DISABLED"
            fi
            ;;
        env-proxy)
            local protocol proxy_addr
            protocol=$(get_terminal_proxy_protocol)
            proxy_addr=$(get_proxy_address "$protocol")

            print --purple "Manual Proxy Environment Variables:"
            echo "export http_proxy=$protocol://$proxy_addr"
            echo "export https_proxy=$protocol://$proxy_addr"  
            echo "export ftp_proxy=$protocol://$proxy_addr"
            echo "export no_proxy=$NO_PROXY_LIST"
            echo ""
            print --info "To apply in current shell:"
            print --cyan 'eval "$(xrayctl env-proxy | grep export)"'
            ;;
        global-enable)
            print --purple "🚀 Starting Xray and enabling all proxy settings..."
            echo ""

            # Запустить и включить xray сервис
            systemctl --user start xray
            systemctl --user enable xray
            print --success "Xray service started and enabled"

            # Получить настройки прокси для системы
            local system_protocol system_proxy_addr
            system_protocol=$(get_system_proxy_protocol)
            system_proxy_addr=$(get_proxy_address "$system_protocol")

            # Получить настройки прокси для терминала
            local terminal_protocol terminal_proxy_addr
            terminal_protocol=$(get_terminal_proxy_protocol)
            terminal_proxy_addr=$(get_proxy_address "$terminal_protocol")

            # Включить прокси
            enable_system_proxy "$system_proxy_addr" "$system_protocol" 2>/dev/null || true
            enable_terminal_proxy "$terminal_proxy_addr" "$terminal_protocol"

            echo ""
            print --purple "🎉 All proxy settings enabled!"
            print --cyan "   • Xray service: ${GREEN}RUNNING${NC}"
            print --cyan "   • System proxy (GNOME): ${GREEN}ENABLED${NC}"
            print --cyan "   • Terminal proxy: ${GREEN}ENABLED${NC}"
            ;;
        global-disable)
            print --purple "🔒 Disabling all proxy settings..."
            echo ""

            # Остановить xray сервис
            systemctl --user stop xray
            print --success "Xray service stopped"

            # Выключить системный и терминальный прокси
            disable_system_proxy 2>/dev/null || true
            disable_terminal_proxy

            echo ""
            print --purple "🔒 All proxy settings disabled!"
            print --cyan "   • Xray service: ${RED}STOPPED${NC}"
            print --cyan "   • System proxy (GNOME): ${RED}DISABLED${NC}"
            print --cyan "   • Terminal proxy: ${RED}DISABLED${NC}"
            echo ""
            print --info "Restart terminal to apply terminal proxy changes"
            ;;
        clear-env)
            print --purple "🧹 Clearing proxy environment variables..."
            clear_proxy_env
            print --success "Proxy environment variables cleared"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# Показать справку
show_help() {
    print --purple "🔧 Xray User Management Tool"
    echo ""
    print --info "Usage: xrayctl {command}"
    echo ""

    print --cyan "🚀 Quick commands:"
    echo -e "  ${GREEN}global-enable${NC}          Start Xray + enable global proxy settings"
    echo -e "  ${RED}global-disable${NC}         Stop Xray + disable global proxy settings"
    echo ""

    print --cyan "⚙️ Service management:"
    echo -e "  ${GREEN}service-enable${NC}         Enable autostart"
    echo -e "  ${GREEN}service-start${NC}          Start Xray service"
    echo -e "  ${RED}service-stop${NC}           Stop Xray service"
    echo -e "  ${CYAN}service-restart${NC}        Restart Xray service"
    echo -e "  ${RED}service-disable${NC}        Disable autostart"
    echo -e "  ${BLUE}service-status${NC}         Show service status"
    echo -e "  ${BLUE}service-logs${NC}           Show service logs"
    echo ""

    print --cyan "🌐 System proxy (GNOME):"
    echo -e "  ${GREEN}system-enable${NC}          Enable system-wide proxy"
    echo -e "  ${RED}system-disable${NC}         Disable system-wide proxy"
    echo -e "  ${BLUE}system-status${NC}          Show system proxy status"
    echo ""

    print --cyan "💻 Terminal proxy:"
    echo -e "  ${GREEN}terminal-enable${NC}        Enable terminal proxy (persistent)"
    echo -e "  ${RED}terminal-disable${NC}       Disable terminal proxy"
    echo -e "  ${BLUE}terminal-status${NC}        Show terminal proxy status"
    echo -e "  ${YELLOW}env-proxy${NC}              Show manual environment variables"
    echo -e "  ${YELLOW}clear-env${NC}              Clear proxy environment variables"
    echo ""

    print --cyan "📋 Configuration:"
    echo -e "  ${PURPLE}config${NC}                 Show config file paths"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

check-packages print check-user ensure-config jq gsettings systemctl grep

check-user

ensure-config "$CONFIG_DIR" "$CONFIG_FILE"

main "$@"