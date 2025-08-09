{pkgs, ...}: {
  home.packages = with pkgs; [
    # WhatsApp Web как нативное приложение
    (makeDesktopItem {
      name = "whatsapp-web";
      desktopName = "WhatsApp Web";
      exec = "${brave}/bin/brave --app=https://web.whatsapp.com/ --class=whatsapp-web --user-data-dir=\"$HOME/.config/whatsapp-web\"";
      icon = "whatsapp";
      categories = ["Network" "InstantMessaging"];
      comment = "WhatsApp Web application";
      startupNotify = true;
      startupWMClass = "whatsapp-web";
    })

    # YouTube Music
    (makeDesktopItem {
      name = "youtube-music";
      desktopName = "YouTube Music";
      exec = "${brave}/bin/brave --app=https://music.youtube.com/ --class=youtube-music --user-data-dir=\"$HOME/.config/youtube-music\"";
      icon = "youtube";
      categories = ["AudioVideo" "Audio" "Player"];
      comment = "YouTube Music web application";
      startupNotify = true;
      startupWMClass = "youtube-music";
    })

    # Telegram Web
    (makeDesktopItem {
      name = "telegram-web";
      desktopName = "Telegram Web";
      exec = "${brave}/bin/brave --app=https://web.telegram.org/ --class=telegram-web --user-data-dir=\"$HOME/.config/telegram-web\"";
      icon = "telegram";
      categories = ["Network" "InstantMessaging"];
      comment = "Telegram Web application";
      startupNotify = true;
      startupWMClass = "telegram-web";
    })

    # Discord Web
    (makeDesktopItem {
      name = "discord-web";
      desktopName = "Discord Web";
      exec = "${brave}/bin/brave --app=https://discord.com/app --class=discord-web --user-data-dir=\"$HOME/.config/discord-web\"";
      icon = "discord";
      categories = ["Network" "InstantMessaging"];
      comment = "Discord Web application";
      startupNotify = true;
      startupWMClass = "discord-web";
    })

    # Gmail
    (makeDesktopItem {
      name = "gmail-web";
      desktopName = "Gmail";
      exec = "${brave}/bin/brave --app=https://mail.google.com/ --class=gmail-web --user-data-dir=\"$HOME/.config/gmail-web\"";
      icon = "gmail";
      categories = ["Network" "Email"];
      comment = "Gmail web application";
      startupNotify = true;
      startupWMClass = "gmail-web";
    })
  ];
}