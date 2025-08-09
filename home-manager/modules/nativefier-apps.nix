{pkgs, ...}: 
let
  # Простой wrapper для npx nativefier (самый надежный способ)
  nativefier = pkgs.writeShellScriptBin "nativefier" ''
    export PATH="${pkgs.nodejs}/bin:${pkgs.electron}/bin:$PATH"
    export ELECTRON_OVERRIDE_DIST_PATH="${pkgs.electron}/bin/"
    
    # Устанавливаем nativefier в временную директорию при первом запуске
    NPM_CACHE="$HOME/.cache/nativefier-npm"
    mkdir -p "$NPM_CACHE"
    
    # Используем npx для запуска последней версии
    exec ${pkgs.nodejs}/bin/npx --cache "$NPM_CACHE" nativefier@latest "$@"
  '';

  # Функция для создания нативного веб-приложения
  makeWebApp = {name, url, icon ? name, userAgent ? null}: 
    pkgs.writeShellScriptBin name ''
      APP_DIR="$HOME/.local/share/nativefier-apps"
      DESKTOP_DIR="$HOME/.local/share/applications"
      ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
      
      mkdir -p "$APP_DIR"
      mkdir -p "$DESKTOP_DIR"
      mkdir -p "$ICON_DIR"
      
      # Создаем приложение если его еще нет
      if [ ! -d "$APP_DIR/${name}-linux-x64" ]; then
        echo "🔧 Creating ${name} app..."
        ${nativefier}/bin/nativefier \
          --name "${name}" \
          --platform linux \
          --arch x64 \
          --electron-version latest \
          ${if userAgent != null then "--user-agent \"${userAgent}\"" else ""} \
          --single-instance \
          --tray \
          --counter \
          --bounce \
          --fast-quit \
          --app-copyright "Web App" \
          --app-version "1.0.0" \
          --out "$APP_DIR" \
          "${url}"
        
        # Создаем .desktop файл после успешного создания приложения
        if [ -d "$APP_DIR/${name}-linux-x64" ]; then
          cat > "$DESKTOP_DIR/${name}.desktop" <<EOF
          [Desktop Entry]
          Name=${name}
          Comment=Web Application
          Exec=$HOME/.local/share/nativefier-apps/${name}-linux-x64/${name}
          Icon=$HOME/.local/share/nativefier-apps/${name}-linux-x64/resources/app/icon.png
          Terminal=false
          Type=Application
          Categories=Network;WebBrowser;
          Keywords=web;app;${name};
          EOF
          
          echo "📱 Desktop entry created: $DESKTOP_DIR/${name}.desktop"
          
          # Копируем иконку если она есть
          if [ -f "$APP_DIR/${name}-linux-x64/resources/app/icon.png" ]; then
            cp "$APP_DIR/${name}-linux-x64/resources/app/icon.png" "$ICON_DIR/${name}.png"
            echo "🖼️  Icon copied to system icons"
          fi
          
          echo "✅ ${name} app created successfully!"
        fi
      fi
      
      # Запуск приложения
      if [ -d "$APP_DIR/${name}-linux-x64" ]; then
        exec "$APP_DIR/${name}-linux-x64/${name}" "$@"
      else
        echo "❌ Failed to create ${name} app" >&2
        exit 1
      fi
    '';

  # WhatsApp Web с правильным User-Agent
  whatsappWeb = makeWebApp {
    name = "whatsapp-web";
    url = "https://web.whatsapp.com/";
    userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
  };

  # Telegram Web
  telegramWeb = makeWebApp {
    name = "telegram-web";
    url = "https://web.telegram.org/z/";
  };

  # YouTube Music
  youtubeMusicWeb = makeWebApp {
    name = "youtube-music";
    url = "https://music.youtube.com/";
  };

  # Discord Web
  discordWeb = makeWebApp {
    name = "discord-web";  
    url = "https://discord.com/app";
  };

  # Gmail
  gmailWeb = makeWebApp {
    name = "gmail";
    url = "https://mail.google.com/";
  };

  # Скрипт для управления приложениями
  manageNativefierApps = pkgs.writeShellScriptBin "manage-nativefier-apps" ''
    #!/bin/bash
    
    APP_DIR="$HOME/.local/share/nativefier-apps"
    DESKTOP_DIR="$HOME/.local/share/applications"
    
    case "$1" in
      "list")
        echo "📱 Available Nativefier apps:"
        if [ -d "$APP_DIR" ]; then
          ls -la "$APP_DIR" | grep -E "linux-x64$" | while read line; do
            app_name=$(echo "$line" | awk '{print $9}' | sed 's/-linux-x64$//')
            echo "  • $app_name"
          done
        else
          echo "  No apps found"
        fi
        ;;
      "remove")
        if [ -z "$2" ]; then
          echo "Usage: manage-nativefier-apps remove <app-name>"
          exit 1
        fi
        app_name="$2"
        if [ -d "$APP_DIR/${app_name}-linux-x64" ]; then
          rm -rf "$APP_DIR/${app_name}-linux-x64"
          rm -f "$DESKTOP_DIR/${app_name}.desktop"
          echo "✅ Removed $app_name app"
        else
          echo "❌ App $app_name not found"
        fi
        ;;
      "clean")
        echo "🧹 Cleaning all Nativefier apps..."
        rm -rf "$APP_DIR"
        rm -f "$DESKTOP_DIR"/*.desktop
        echo "✅ All apps removed"
        ;;
      *)
        echo "Usage: manage-nativefier-apps {list|remove <app>|clean}"
        echo ""
        echo "Commands:"
        echo "  list                    - List all available apps"
        echo "  remove <app-name>      - Remove specific app"
        echo "  clean                  - Remove all apps"
        ;;
    esac
  '';

in {
  home.packages = [
    nativefier
    whatsappWeb
    telegramWeb
    youtubeMusicWeb
    discordWeb
    gmailWeb
    manageNativefierApps
  ];

  # Создать директории для nativefier приложений
  home.file.".local/share/nativefier-apps/.keep".text = "";
  home.file.".local/share/applications/.keep".text = "";
}