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
      mkdir -p "$APP_DIR"
      
      # Создаем приложение если его еще нет
      if [ ! -d "$APP_DIR/${name}-linux-x64" ]; then
        echo "Creating ${name} app..."
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
      fi
      
      # Запуск приложения
      if [ -d "$APP_DIR/${name}-linux-x64" ]; then
        exec "$APP_DIR/${name}-linux-x64/${name}" "$@"
      else
        echo "Failed to create ${name} app" >&2
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

in {
  home.packages = [
    nativefier
    whatsappWeb
    telegramWeb
    youtubeMusicWeb
    discordWeb
    gmailWeb
  ];

  # Создать директорию для nativefier приложений
  home.file.".local/share/nativefier-apps/.keep".text = "";
}