#!/usr/bin/env bash

# Автоматически создать config.json из примера если его нет
ensure_config() {
  if [ ! -f "@configFile@" ]; then
    echo "Creating default config from example..."
    cp ~/.config/xray/config/config.example.json "@configFile@"
    echo "Config created at: @configFile@"
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
    echo "System proxy enabled (SOCKS $host:$port)"
  else
    @gsettings@/bin/gsettings set org.gnome.system.proxy.http host "$host"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.http port "$port"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.https host "$host"
    @gsettings@/bin/gsettings set org.gnome.system.proxy.https port "$port"
    echo "System proxy enabled (HTTP $host:$port)"
  fi
}

# Отключить системный прокси GNOME
disable_system_proxy() {
  @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'none'
  echo "System proxy disabled"
}

# Создать файлы с proxy переменными для терминала
create_proxy_env_files() {
  local proxy_addr="$1"
  local protocol="$2"
  
  mkdir -p ~/.config/xray
  
  # Bash/Zsh версия
  cat > ~/.config/xray/proxy-env <<EOF
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
  cat > ~/.config/xray/proxy-env.fish <<FISH_VARS
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
  if [ -d ~/.config/fish ]; then
    echo "fish ~/.config/fish/conf.d/xray-proxy.fish"
  elif [ -f ~/.bashrc ]; then
    echo "bash ~/.bashrc"
  elif [ -f ~/.zshrc ]; then
    echo "zsh ~/.zshrc"
  else
    echo "unknown"
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
# Xray proxy environment (managed by xray-user)
if test -f ~/.config/xray/proxy-env.fish; and test -f ~/.config/xray/.proxy-enabled
  source ~/.config/xray/proxy-env.fish
end
FISH_EOF
      echo "Created Fish proxy config: $profile_path"
    else
      echo "Fish proxy config already exists: $profile_path"
    fi
  else
    if ! grep -q "xray/proxy-env" "$profile_path"; then
      echo "" >> "$profile_path"
      echo "# Xray proxy environment (managed by xray-user)" >> "$profile_path"
      echo 'if [ -f ~/.config/xray/proxy-env ] && [ -f ~/.config/xray/.proxy-enabled ]; then' >> "$profile_path"
      echo '  source ~/.config/xray/proxy-env' >> "$profile_path"
      echo 'fi' >> "$profile_path"
      echo "Added proxy config to $profile_path"
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
  touch ~/.config/xray/.proxy-enabled
  
  echo "Terminal proxy enabled ($protocol://$proxy_addr)!"
  if [ "$shell_type" = "fish" ]; then
    echo "Restart terminal or run: source ~/.config/xray/proxy-env.fish"
  else
    echo "Restart terminal or run: source ~/.config/xray/proxy-env"
  fi
}

# Отключить терминальный прокси
disable_terminal_proxy() {
  rm -f ~/.config/xray/.proxy-enabled
  echo "Terminal proxy disabled!"
  echo "Restart terminal to apply changes"
}

case "$1" in
  start)
    ensure_config
    systemctl --user start xray
    echo "Xray service started"
    ;;
  stop)
    systemctl --user stop xray
    echo "Xray service stopped"
    ;;
  restart)
    ensure_config
    systemctl --user restart xray
    echo "Xray service restarted"
    ;;
  status)
    systemctl --user status xray
    ;;
  logs)
    journalctl --user -u xray -f
    ;;
  enable)
    ensure_config
    systemctl --user enable xray
    echo "Xray service enabled for autostart"
    ;;
  disable)
    systemctl --user disable xray
    echo "Xray service disabled from autostart"
    ;;
  config)
    ensure_config
    echo "Config file: @configFile@"
    echo "Example file: @homeDirectory@/.config/xray/config.example.json"
    ;;
  proxy-on)
    ensure_config
    local proxy_addr protocol
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    enable_system_proxy "$proxy_addr" "$protocol"
    echo "Browser and most apps will now use proxy"
    ;;
  proxy-off)
    disable_system_proxy
    ;;
  proxy-status)
    mode=$(@gsettings@/bin/gsettings get org.gnome.system.proxy mode)
    if [ "$mode" = "'manual'" ]; then
      host=$(@gsettings@/bin/gsettings get org.gnome.system.proxy.socks host)
      port=$(@gsettings@/bin/gsettings get org.gnome.system.proxy.socks port)
      echo "System proxy: ENABLED ($host:$port)"
    else
      echo "System proxy: DISABLED"
    fi
    ;;
  terminal-proxy-on)
    ensure_config
    local proxy_addr protocol
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    enable_terminal_proxy "$proxy_addr" "$protocol"
    ;;
  terminal-proxy-off)
    disable_terminal_proxy
    ;;
  terminal-proxy-status)
    if [ -f ~/.config/xray/.proxy-enabled ]; then
      echo "Terminal proxy: ENABLED"
      if [ -n "$http_proxy" ]; then
        echo "Current session: ACTIVE ($http_proxy)"
      else
        echo "Current session: INACTIVE (restart terminal)"
      fi
    else
      echo "Terminal proxy: DISABLED"
    fi
    ;;
  env-proxy)
    ensure_config
    local proxy_addr protocol
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    echo "# Manual proxy environment variables (from current config):"
    echo "export http_proxy=$protocol://$proxy_addr"
    echo "export https_proxy=$protocol://$proxy_addr"  
    echo "export ftp_proxy=$protocol://$proxy_addr"
    echo "export no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8"
    echo ""
    echo "To apply in current shell:"
    echo 'eval "$(xray-user env-proxy | grep export)"'
    ;;
  all-on)
    echo "Starting Xray and enabling all proxy settings..."
    echo ""
    
    # Запустить и включить xray сервис
    ensure_config
    systemctl --user start xray
    systemctl --user enable xray
    echo "✓ Xray service started and enabled"
    
    # Получить настройки прокси
    local proxy_addr protocol shell_type
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    # Включить системный прокси для GNOME
    enable_system_proxy "$proxy_addr" "$protocol"
    echo "✓ GNOME $(echo "$proxy_addr" | cut -d: -f1):$(echo "$proxy_addr" | cut -d: -f2) proxy enabled"
    
    # Включить терминальный прокси
    create_proxy_env_files "$proxy_addr" "$protocol"
    shell_type=$(setup_shell_profile)
    touch ~/.config/xray/.proxy-enabled
    echo "✓ Terminal proxy enabled for $shell_type shell"
    
    echo ""
    echo "🎉 All proxy settings enabled!"
    echo "   • Xray service: RUNNING"
    echo "   • System proxy (GNOME): ENABLED"
    echo "   • Terminal proxy: ENABLED"
    echo ""
    if [ "$shell_type" = "fish" ]; then
      echo "Restart terminal to apply terminal proxy changes"
    else
      echo "Restart terminal or run: source ~/.config/xray/proxy-env"
    fi
    ;;
  all-off)
    echo "Disabling all proxy settings..."
    echo ""
    
    # Остановить xray сервис
    systemctl --user stop xray
    echo "✓ Xray service stopped"
    
    # Выключить системный и терминальный прокси
    disable_system_proxy
    echo "✓ GNOME system proxy disabled"
    
    disable_terminal_proxy
    echo "✓ Terminal proxy disabled"
    
    echo ""
    echo "🔒 All proxy settings disabled!"
    echo "   • Xray service: STOPPED"
    echo "   • System proxy (GNOME): DISABLED"
    echo "   • Terminal proxy: DISABLED"
    echo ""
    echo "Restart terminal to apply terminal proxy changes"
    ;;
  *)
    echo "Usage: xray-user {start|stop|restart|status|logs|enable|disable|config|proxy-on|proxy-off|proxy-status|terminal-proxy-on|terminal-proxy-off|terminal-proxy-status|env-proxy|all-on|all-off}"
    echo ""
    echo "Quick commands:"
    echo "  all-on                 Start Xray + enable all proxy settings"
    echo "  all-off                Stop Xray + disable all proxy settings"
    echo ""
    echo "System proxy commands:"
    echo "  proxy-on               Enable GNOME system-wide proxy"
    echo "  proxy-off              Disable GNOME system-wide proxy" 
    echo "  proxy-status           Show current system proxy status"
    echo ""
    echo "Terminal proxy commands:"
    echo "  terminal-proxy-on      Enable terminal proxy (persistent)"
    echo "  terminal-proxy-off     Disable terminal proxy"
    echo "  terminal-proxy-status  Show terminal proxy status"
    echo "  env-proxy              Show manual environment variables"
    exit 1
    ;;
esac