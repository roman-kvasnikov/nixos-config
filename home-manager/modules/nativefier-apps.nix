{pkgs, ...}: 
let
  # Функция для создания нативного веб-приложения
  makeWebApp = {name, url, icon ? name, userAgent ? null}: 
    pkgs.writeShellScriptBin name ''
      ${pkgs.nativefier}/bin/nativefier \
        --name "${name}" \
        --platform linux \
        --arch x64 \
        --electron-version latest \
        --overwrite \
        ${if userAgent != null then "--user-agent \"${userAgent}\"" else ""} \
        --single-instance \
        --tray \
        --counter \
        --bounce \
        --fast-quit \
        --app-copyright "Web App" \
        --app-version "1.0.0" \
        --out "$HOME/.local/share/nativefier-apps" \
        "${url}"
      
      # Запуск приложения после создания
      if [ -d "$HOME/.local/share/nativefier-apps/${name}-linux-x64" ]; then
        "$HOME/.local/share/nativefier-apps/${name}-linux-x64/${name}" "$@"
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
  home.packages = with pkgs; [
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