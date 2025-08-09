#!/usr/bin/env bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Функции для красивого вывода
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
  echo -e "${RED}[✗]${NC} $1"
}

print_header() {
  echo -e "${PURPLE}$1${NC}"
}

print_status() {
  echo -e "${CYAN}$1${NC}"
}

# Автоматически создать config.json из примера если его нет
ensure_config() {
  if [ ! -f "@configFile@" ]; then
    print_info "Creating default config from example..."
    cp "$HOME/.config/xray/config/config.example.json" "@configFile@"
    print_success "Config created at: @configFile@"
  fi
}

# Получить настройки прокси из config.json
get_proxy_settings() {
  if [ ! -f "@configFile@" ]; then
    echo "127.0.0.1:1080"  # fallback
    return
  fi
  
  # Найти первый SOCKS inbound
  local host port
  host=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .listen // "127.0.0.1"' "@configFile@" 2>/dev/null | head -1)
  port=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .port' "@configFile@" 2>/dev/null | head -1)
  
  # Если не найден SOCKS, попробовать HTTP
  if [ -z "$host" ] || [ -z "$port" ] || [ "$host" = "null" ] || [ "$port" = "null" ]; then
    host=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .listen // "127.0.0.1"' "@configFile@" 2>/dev/null | head -1)
    port=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .port' "@configFile@" 2>/dev/null | head -1)
  fi
  
  # Fallback если ничего не найдено
  if [ -z "$host" ] || [ -z "$port" ] || [ "$host" = "null" ] || [ "$port" = "null" ]; then
    echo "127.0.0.1:1080"
  else
    echo "$host:$port"
  fi
}

# Получить настройки прокси для конкретного протокола
get_proxy_settings_for_protocol() {
  local protocol="$1"
  
  if [ ! -f "@configFile@" ]; then
    if [ "$protocol" = "http" ]; then
      echo "127.0.0.1:10809"  # fallback для HTTP
    else
      echo "127.0.0.1:10808"  # fallback для SOCKS
    fi
    return
  fi
  
  local host port
  if [ "$protocol" = "http" ]; then
    host=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .listen // "127.0.0.1"' "@configFile@" 2>/dev/null | head -1)
    port=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .port' "@configFile@" 2>/dev/null | head -1)
  else
    host=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .listen // "127.0.0.1"' "@configFile@" 2>/dev/null | head -1)
    port=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .port' "@configFile@" 2>/dev/null | head -1)
  fi
  
  if [ -z "$host" ] || [ "$host" = "null" ]; then
    host="127.0.0.1"
  fi
  
  if [ -z "$port" ] || [ "$port" = "null" ]; then
    if [ "$protocol" = "http" ]; then
      port="10809"  # fallback для HTTP
    else
      port="10808"  # fallback для SOCKS
    fi
  fi
  
  echo "$host:$port"
}

# Получить протокол прокси из config.json
get_proxy_protocol() {
  if [ ! -f "@configFile@" ]; then
    echo "socks5"  # fallback
    return
  fi
  
  # Проверить есть ли SOCKS
  local has_socks has_http
  has_socks=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .protocol' "@configFile@" 2>/dev/null | head -1)
  
  if [ "$has_socks" = "socks" ]; then
    echo "socks5"
  else
    # Проверить HTTP
    has_http=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .protocol' "@configFile@" 2>/dev/null | head -1)
    if [ "$has_http" = "http" ]; then
      echo "http"
    else
      echo "socks5"  # fallback
    fi
  fi
}

# Получить протокол прокси для терминальных команд (предпочитает HTTP для совместимости с wget/curl)
get_terminal_proxy_protocol() {
  if [ ! -f "@configFile@" ]; then
    echo "http"  # fallback
    return
  fi
  
  # Сначала проверить HTTP (для совместимости с wget)
  local has_http has_socks
  has_http=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "http") | .protocol' "@configFile@" 2>/dev/null | head -1)
  
  if [ "$has_http" = "http" ]; then
    echo "http"
  else
    # Если HTTP нет, проверить SOCKS
    has_socks=$(@jq@/bin/jq -r '.inbounds[]? | select(.protocol == "socks") | .protocol' "@configFile@" 2>/dev/null | head -1)
    if [ "$has_socks" = "socks" ]; then
      echo "socks5"
    else
      echo "http"  # fallback
    fi
  fi
}

# Включить системный прокси GNOME
enable_system_proxy() {
  local proxy_addr="$1"
  local protocol="$2"
  local host port
  
  host=$(echo "$proxy_addr" | cut -d: -f1)
  port=$(echo "$proxy_addr" | cut -d: -f2)
  
  @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'manual'
  
  if [ "$protocol" = "socks5" ]; then
    @gsettings@/bin/gsettings set org.gnome.system.proxy.socks host "$host"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.socks port "$port"
    print_success "GNOME system proxy enabled (SOCKS $host:$port)"
  else
    @gsettings@/bin/gsettings set org.gnome.system.proxy.http host "$host"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.http port "$port"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.https host "$host"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.https port "$port"
    print_success "GNOME system proxy enabled (HTTP $host:$port)"
  fi
}

# Отключить системный прокси GNOME
disable_system_proxy() {
  @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'none'
  print_success "GNOME system proxy disabled"
}

# Создать файлы с proxy переменными для терминала
create_proxy_env_files() {
  local proxy_addr="$1"
  local protocol="$2"
  
  mkdir -p "$HOME/.config/xray"
  
  # Bash/Zsh версия
  cat > "$HOME/.config/xray/proxy-env" <<EOF
export http_proxy=$protocol://$proxy_addr
export https_proxy=$protocol://$proxy_addr
export ftp_proxy=$protocol://$proxy_addr
export HTTP_PROXY=$protocol://$proxy_addr
export HTTPS_PROXY=$protocol://$proxy_addr
export FTP_PROXY=$protocol://$proxy_addr
export no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
export NO_PROXY=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
EOF
  
  # Fish версия
  cat > "$HOME/.config/xray/proxy-env.fish" <<FISH_VARS
set -x http_proxy $protocol://$proxy_addr
set -x https_proxy $protocol://$proxy_addr  
set -x ftp_proxy $protocol://$proxy_addr
set -x HTTP_PROXY $protocol://$proxy_addr
set -x HTTPS_PROXY $protocol://$proxy_addr
set -x FTP_PROXY $protocol://$proxy_addr
set -x no_proxy localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
set -x NO_PROXY localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12
FISH_VARS
}

# Определить тип shell и путь к профилю
detect_shell_profile() {
  # Проверить текущий SHELL пользователя
  if [[ "$SHELL" == *"fish"* ]] || command -v fish >/dev/null 2>&1; then
    echo "fish $HOME/.config/fish/conf.d/xray-proxy.fish"
  elif [[ "$SHELL" == *"zsh"* ]] && [ -f "$HOME/.zshrc" ]; then
    echo "zsh $HOME/.zshrc"
  elif [[ "$SHELL" == *"bash"* ]] || [ -f "$HOME/.bashrc" ]; then
    echo "bash $HOME/.bashrc"
  else
    # Fallback к bash если ничего не найдено
    echo "bash $HOME/.bashrc"
  fi
}

# Настроить shell профиль для автозагрузки прокси
setup_shell_profile() {
  local shell_info profile_path shell_type
  
  shell_info=$(detect_shell_profile)
  shell_type=$(echo "$shell_info" | cut -d' ' -f1)
  profile_path=$(echo "$shell_info" | cut -d' ' -f2)
  
  if [ "$shell_type" = "unknown" ]; then
    return
  fi
  
  if [ "$shell_type" = "fish" ]; then
    mkdir -p "$(dirname "$profile_path")"
    if [ ! -f "$profile_path" ]; then
      cat > "$profile_path" <<FISH_EOF
# Xray proxy environment (managed by xrayctl)
if test -f $HOME/.config/xray/proxy-env.fish; and test -f $HOME/.config/xray/.proxy-enabled
  source $HOME/.config/xray/proxy-env.fish
end
FISH_EOF
      print_success "Created Fish proxy config: $profile_path"
    else
      print_info "Fish proxy config already exists: $profile_path"
    fi
  else
    if ! grep -q "xray/proxy-env" "$profile_path"; then
      echo "" >> "$profile_path"
      echo "# Xray proxy environment (managed by xrayctl)" >> "$profile_path"
      echo 'if [ -f $HOME/.config/xray/proxy-env ] && [ -f $HOME/.config/xray/.proxy-enabled ]; then' >> "$profile_path"
      echo '  source $HOME/.config/xray/proxy-env' >> "$profile_path"
      echo 'fi' >> "$profile_path"
      print_success "Added proxy config to $profile_path"
    fi
  fi
  
  echo "$shell_type"
}

# Включить терминальный прокси
enable_terminal_proxy() {
  local proxy_addr="$1"
  local protocol="$2"
  local shell_type
  
  create_proxy_env_files "$proxy_addr" "$protocol"
  shell_type=$(setup_shell_profile)
  touch "$HOME/.config/xray/.proxy-enabled"
  
  print_success "Terminal proxy enabled ($protocol://$proxy_addr)"
  echo ""
  print_warning "To use proxy in current session, run:"
  if [ "$shell_type" = "fish" ]; then
    print_status "source $HOME/.config/xray/proxy-env.fish"
    print_info "Or restart terminal (Fish will auto-load on new sessions)"
  else
    print_status "source $HOME/.config/xray/proxy-env"
    print_info "Or restart terminal (will auto-load on new sessions)"
  fi
}

# Отключить терминальный прокси
disable_terminal_proxy() {
  local shell_info shell_type profile_path
  
  # Удалить маркер
  rm -f "$HOME/.config/xray/.proxy-enabled"
  
  # Удалить файлы переменных окружения
  rm -f "$HOME/.config/xray/proxy-env"
  rm -f "$HOME/.config/xray/proxy-env.fish"
  
  # Очистить переменные прокси в текущей сессии
  unset http_proxy https_proxy ftp_proxy no_proxy
  unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY
  
  # Очистить автозагрузку из shell профиля
  shell_info=$(detect_shell_profile)
  shell_type=$(echo "$shell_info" | cut -d' ' -f1)
  profile_path=$(echo "$shell_info" | cut -d' ' -f2)
  
  if [ "$shell_type" = "fish" ]; then
    rm -f "$HOME/.config/fish/conf.d/xray-proxy.fish"
  else
    # Удалить строки из .bashrc/.zshrc
    if [ -f "$profile_path" ]; then
      sed -i '/# Xray proxy start/,/# Xray proxy end/d' "$profile_path"
    fi
  fi
  
  print_success "Terminal proxy disabled"
  print_info "Environment variables cleared in current session"
  print_info "Restart terminal to fully apply changes"
}

case "$1" in
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
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    enable_system_proxy "$proxy_addr" "$protocol"
    print_info "Browser and most apps will now use proxy"
    ;;
  proxy-off)
    disable_system_proxy
    ;;
  proxy-status)
    print_header "System Proxy Status:"
    mode=$(@gsettings@/bin/gsettings get org.gnome.system.proxy mode)
    if [ "$mode" = "'manual'" ]; then
      host=$(@gsettings@/bin/gsettings get org.gnome.system.proxy.socks host)
      port=$(@gsettings@/bin/gsettings get org.gnome.system.proxy.socks port)
      print_success "System proxy: ENABLED ($host:$port)"
    else
      print_status "System proxy: DISABLED"
    fi
    ;;
  terminal-proxy-on)
    ensure_config
    protocol=$(get_terminal_proxy_protocol)
    proxy_addr=$(get_proxy_settings_for_protocol "$protocol")
    
    enable_terminal_proxy "$proxy_addr" "$protocol"
    ;;
  terminal-proxy-off)
    disable_terminal_proxy
    ;;
  terminal-proxy-status)
    print_header "Terminal Proxy Status:"
    if [ -f "$HOME/.config/xray/.proxy-enabled" ]; then
      print_success "Terminal proxy: ENABLED"
      if [ -n "$http_proxy" ]; then
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
    protocol=$(get_terminal_proxy_protocol)
    proxy_addr=$(get_proxy_settings_for_protocol "$protocol")
    
    print_header "Manual Proxy Environment Variables:"
    echo "export http_proxy=$protocol://$proxy_addr"
    echo "export https_proxy=$protocol://$proxy_addr"  
    echo "export ftp_proxy=$protocol://$proxy_addr"
    echo "export no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8"
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
    
    # Получить настройки прокси
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    # Включить системный прокси для GNOME
    enable_system_proxy "$proxy_addr" "$protocol"
    
    # Включить терминальный прокси  
    terminal_protocol=$(get_terminal_proxy_protocol)
    terminal_proxy_addr=$(get_proxy_settings_for_protocol "$terminal_protocol")
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
    
    # Очистить переменные прокси в текущей сессии
    unset http_proxy https_proxy ftp_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY
    
    print_success "Proxy environment variables cleared"
    ;;
  *)
    print_header "🔧 Xray User Management Tool"
    echo ""
    print_info "Usage: xrayctl {command}"
    echo ""
    
    print_status "🚀 Quick commands:"
    echo "  ${GREEN}all-on${NC}                 Start Xray + enable all proxy settings"
    echo "  ${RED}all-off${NC}                Stop Xray + disable all proxy settings"
    echo ""
    
    print_status "⚙️  Service management:"
    echo "  ${CYAN}start${NC}                  Start Xray service"
    echo "  ${CYAN}stop${NC}                   Stop Xray service"
    echo "  ${CYAN}restart${NC}                Restart Xray service"
    echo "  ${CYAN}status${NC}                 Show service status"
    echo "  ${CYAN}logs${NC}                   Show service logs"
    echo "  ${CYAN}enable${NC}                 Enable autostart"
    echo "  ${CYAN}disable${NC}                Disable autostart"
    echo ""
    
    print_status "🌐 System proxy (GNOME):"
    echo "  ${GREEN}proxy-on${NC}               Enable system-wide proxy"
    echo "  ${RED}proxy-off${NC}              Disable system-wide proxy"
    echo "  ${BLUE}proxy-status${NC}           Show system proxy status"
    echo ""
    
    print_status "💻 Terminal proxy:"
    echo "  ${GREEN}terminal-proxy-on${NC}      Enable terminal proxy (persistent)"
    echo "  ${RED}terminal-proxy-off${NC}     Disable terminal proxy"
    echo "  ${BLUE}terminal-proxy-status${NC}  Show terminal proxy status"
    echo "  ${YELLOW}env-proxy${NC}              Show manual environment variables"
    echo "  ${YELLOW}clear-env${NC}              Clear proxy environment variables"
    echo ""
    
    print_status "📋 Configuration:"
    echo "  ${PURPLE}config${NC}                 Show config file paths"
    exit 1
    ;;
esac