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
      set -e  # Остановка при ошибке
      
      APP_DIR="$HOME/.local/share/nativefier-apps"
      DESKTOP_DIR="$HOME/.local/share/applications"
      ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
      
      mkdir -p "$APP_DIR"
      mkdir -p "$DESKTOP_DIR"
      mkdir -p "$ICON_DIR"
      
      # Создаем приложение если его еще нет
      if [ ! -d "$APP_DIR/${name}-linux-x64" ]; then
        echo "🔧 Creating ${name} app..."
        
        # Собираем аргументы для nativefier
        NATIVEFIER_ARGS=(
          --name "${name}"
          --platform linux
          --arch x64
          --electron-version latest
          --single-instance
          --tray
          --counter
          --bounce
          --fast-quit
          --app-copyright "Web App"
          --app-version "1.0.0"
          --out "$APP_DIR"
        )
        
        # Добавляем user-agent если указан
        if [ -n "${userAgent}" ]; then
          NATIVEFIER_ARGS+=(--user-agent "${userAgent}")
        fi
        
        # Добавляем URL в конец
        NATIVEFIER_ARGS+=("${url}")
        
        # Запускаем nativefier
        if ${nativefier}/bin/nativefier "''${NATIVEFIER_ARGS[@]}"; then
          echo "✅ Nativefier completed successfully"
        else
          echo "❌ Nativefier failed to create app"
          exit 1
        fi
        
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
        else
          echo "❌ App directory not found after creation"
          exit 1
        fi
      else
        echo "📱 ${name} app already exists"
      fi
      
      # Запуск приложения
      if [ -d "$APP_DIR/${name}-linux-x64" ]; then
        if [ -f "$APP_DIR/${name}-linux-x64/${name}" ]; then
          exec "$APP_DIR/${name}-linux-x64/${name}" "$@"
        else
          echo "❌ App executable not found: $APP_DIR/${name}-linux-x64/${name}" >&2
          exit 1
        fi
      else
        echo "❌ App directory not found: $APP_DIR/${name}-linux-x64" >&2
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
    
    set -e  # Остановка при ошибке
    
    APP_DIR="$HOME/.local/share/nativefier-apps"
    DESKTOP_DIR="$HOME/.local/share/applications"
    
    # Проверяем существование директорий
    if [ ! -d "$APP_DIR" ]; then
      echo "📁 Creating apps directory: $APP_DIR"
      mkdir -p "$APP_DIR"
    fi
    
    if [ ! -d "$DESKTOP_DIR" ]; then
      echo "📁 Creating desktop directory: $DESKTOP_DIR"
      mkdir -p "$DESKTOP_DIR"
    fi
    
    case "$1" in
      "list")
        echo "📱 Available Nativefier apps:"
        if [ -d "$APP_DIR" ] && [ "$(ls -A "$APP_DIR" 2>/dev/null)" ]; then
          # Используем for цикл вместо while read для решения проблемы с областью видимости
          for app_dir in "$APP_DIR"/*-linux-x64; do
            if [ -d "$app_dir" ]; then
              app_name=$(basename "$app_dir" | sed 's/-linux-x64$//')
              echo "  • $app_name"
            fi
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
          echo "🗑️  Removing $app_name app..."
          rm -rf "$APP_DIR/${app_name}-linux-x64"
          if [ -f "$DESKTOP_DIR/${app_name}.desktop" ]; then
            rm -f "$DESKTOP_DIR/${app_name}.desktop"
            echo "🗑️  Removed desktop entry"
          fi
          echo "✅ Removed $app_name app"
        else
          echo "❌ App $app_name not found"
          exit 1
        fi
        ;;
      "clean")
        echo "🧹 Cleaning all Nativefier apps..."
        if [ -d "$APP_DIR" ]; then
          rm -rf "$APP_DIR"/*
          echo "🗑️  Removed all app directories"
        fi
        
        # Удаляем только .desktop файлы созданные нашими скриптами
        if [ -d "$DESKTOP_DIR" ]; then
          for desktop_file in "$DESKTOP_DIR"/*.desktop; do
            if [ -f "$desktop_file" ]; then
              # Проверяем что это наш .desktop файл
              if grep -q "nativefier-apps" "$desktop_file" 2>/dev/null; then
                rm -f "$desktop_file"
                echo "🗑️  Removed desktop entry: $(basename "$desktop_file")"
              fi
            fi
          done
        fi
        echo "✅ All apps cleaned"
        ;;
      "status")
        echo "📊 Nativefier Apps Status:"
        echo "  Apps directory: $APP_DIR"
        echo "  Desktop directory: $DESKTOP_DIR"
        if [ -d "$APP_DIR" ] && [ "$(ls -A "$APP_DIR" 2>/dev/null)" ]; then
          app_count=$(find "$APP_DIR" -maxdepth 1 -name "*-linux-x64" -type d | wc -l)
          echo "  Installed apps: $app_count"
        else
          echo "  Installed apps: 0"
        fi
        ;;
      *)
        echo "Usage: manage-nativefier-apps {list|remove <app>|clean|status}"
        echo ""
        echo "Commands:"
        echo "  list                    - List all available apps"
        echo "  remove <app-name>      - Remove specific app"
        echo "  clean                  - Remove all apps"
        echo "  status                 - Show status information"
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
