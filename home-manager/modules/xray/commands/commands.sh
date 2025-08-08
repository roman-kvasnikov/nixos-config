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
    local proxy_addr protocol host port
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
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
    
    echo "Browser and most apps will now use proxy"
    ;;
  proxy-off)
    @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'none'
    echo "System proxy disabled"
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
    local proxy_addr protocol host port
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    
    # Создать файлы с proxy переменными
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
    
    # Fish версия (с синтаксисом set -x)
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
    
    # Добавить в shell profile если еще не добавлено
    shell_profile=""
    shell_type=""
    fish_config_dir=""
    
    # Определить тип shell и профиль
    if [ -d ~/.config/fish ]; then
      shell_type="fish"
      fish_config_dir=~/.config/fish
      # Для Fish создаем отдельный файл конфигурации
      shell_profile="$fish_config_dir/conf.d/xray-proxy.fish"
    elif [ -f ~/.bashrc ]; then
      shell_profile=~/.bashrc
      shell_type="bash"
    elif [ -f ~/.zshrc ]; then
      shell_profile=~/.zshrc
      shell_type="zsh"
    fi
    
    if [ -n "$shell_profile" ]; then
      if [ "$shell_type" = "fish" ]; then
        # Для Fish создаем отдельный файл в conf.d/
        mkdir -p "$fish_config_dir/conf.d"
        if [ ! -f "$shell_profile" ]; then
          cat > "$shell_profile" <<FISH_EOF
# Xray proxy environment (managed by xray-user)
if test -f ~/.config/xray/proxy-env.fish; and test -f ~/.config/xray/.proxy-enabled
  source ~/.config/xray/proxy-env.fish
end
FISH_EOF
          echo "Created Fish proxy config: $shell_profile"
        else
          echo "Fish proxy config already exists: $shell_profile"
        fi
      else
        # Для bash/zsh добавляем в основной файл конфигурации
        if ! grep -q "xray/proxy-env" "$shell_profile"; then
          echo "" >> "$shell_profile"
          echo "# Xray proxy environment (managed by xray-user)" >> "$shell_profile"
          echo 'if [ -f ~/.config/xray/proxy-env ] && [ -f ~/.config/xray/.proxy-enabled ]; then' >> "$shell_profile"
          echo '  source ~/.config/xray/proxy-env' >> "$shell_profile"
          echo 'fi' >> "$shell_profile"
          echo "Added proxy config to $shell_profile"
        fi
      fi
    fi
    
    # Включить прокси
    touch ~/.config/xray/.proxy-enabled
    echo "Terminal proxy enabled ($protocol://$proxy_addr)!"
    if [ "$shell_type" = "fish" ]; then
      echo "Restart terminal or run: source ~/.config/xray/proxy-env.fish"
    else
      echo "Restart terminal or run: source ~/.config/xray/proxy-env"
    fi
    ;;
  terminal-proxy-off)
    # Выключить прокси
    rm -f ~/.config/xray/.proxy-enabled
    echo "Terminal proxy disabled!"
    echo "Restart terminal to apply changes"
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
    
    # Включить системный прокси для GNOME
    local proxy_addr protocol host port
    proxy_addr=$(get_proxy_settings)
    protocol=$(get_proxy_protocol)
    host=$(echo "$proxy_addr" | cut -d: -f1)
    port=$(echo "$proxy_addr" | cut -d: -f2)
    
    @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'manual'
    
    if [ "$protocol" = "socks5" ]; then
      @gsettings@/bin/gsettings set org.gnome.system.proxy.socks host "$host"
      @gsettings@/bin/gsettings set org.gnome.system.proxy.socks port "$port"
      echo "✓ GNOME system proxy enabled (SOCKS $host:$port)"
    else
      @gsettings@/bin/gsettings set org.gnome.system.proxy.http host "$host"
      @gsettings@/bin/gsettings set org.gnome.system.proxy.http port "$port"
      @gsettings@/bin/gsettings set org.gnome.system.proxy.https host "$host"
      @gsettings@/bin/gsettings set org.gnome.system.proxy.https port "$port"
      echo "✓ GNOME system proxy enabled (HTTP $host:$port)"
    fi
    
    # Включить терминальный прокси
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
    
    # Настроить shell профили
    shell_profile=""
    shell_type=""
    fish_config_dir=""
    
    if [ -d ~/.config/fish ]; then
      shell_type="fish"
      fish_config_dir=~/.config/fish
      shell_profile="$fish_config_dir/conf.d/xray-proxy.fish"
    elif [ -f ~/.bashrc ]; then
      shell_profile=~/.bashrc
      shell_type="bash"
    elif [ -f ~/.zshrc ]; then
      shell_profile=~/.zshrc
      shell_type="zsh"
    fi
    
    if [ -n "$shell_profile" ]; then
      if [ "$shell_type" = "fish" ]; then
        mkdir -p "$fish_config_dir/conf.d"
        if [ ! -f "$shell_profile" ]; then
          cat > "$shell_profile" <<FISH_EOF
# Xray proxy environment (managed by xray-user)
if test -f ~/.config/xray/proxy-env.fish; and test -f ~/.config/xray/.proxy-enabled
  source ~/.config/xray/proxy-env.fish
end
FISH_EOF
        fi
      else
        if ! grep -q "xray/proxy-env" "$shell_profile"; then
          echo "" >> "$shell_profile"
          echo "# Xray proxy environment (managed by xray-user)" >> "$shell_profile"
          echo 'if [ -f ~/.config/xray/proxy-env ] && [ -f ~/.config/xray/.proxy-enabled ]; then' >> "$shell_profile"
          echo '  source ~/.config/xray/proxy-env' >> "$shell_profile"
          echo 'fi' >> "$shell_profile"
        fi
      fi
    fi
    
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
    
    # Выключить системный прокси
    @gsettings@/bin/gsettings set org.gnome.system.proxy mode 'none'
    echo "✓ GNOME system proxy disabled"
    
    # Выключить терминальный прокси
    rm -f ~/.config/xray/.proxy-enabled
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