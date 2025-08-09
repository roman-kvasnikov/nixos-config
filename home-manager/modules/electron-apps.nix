{pkgs, ...}: 
let
  # Создаем простой wrapper для Electron веб-приложений
  makeElectronApp = {name, url, icon ? name, userAgent ? null, displayName ? name}: 
    let
      electronApp = pkgs.writeShellScriptBin name ''
        # Создаем простой HTML файл для приложения
        APP_DIR="$HOME/.local/share/electron-apps/${name}"
        mkdir -p "$APP_DIR"
        
        cat > "$APP_DIR/index.html" << 'EOF'
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>${displayName}</title>
          <style>
            body { margin: 0; padding: 0; overflow: hidden; }
            webview { width: 100vw; height: 100vh; }
          </style>
        </head>
        <body>
          <webview src="${url}" ${if userAgent != null then "useragent=\"${userAgent}\"" else ""} nodeintegration="false" websecurity="true"></webview>
        </body>
        </html>
        EOF
        
        cat > "$APP_DIR/main.js" << 'EOF'
        const { app, BrowserWindow } = require('electron');
        const path = require('path');
        
        function createWindow() {
          const win = new BrowserWindow({
            width: 1200,
            height: 800,
            webPreferences: {
              nodeIntegration: false,
              contextIsolation: true,
              webSecurity: true
            },
            title: '${displayName}',
            icon: '${icon}'
          });
          
          win.loadFile('index.html');
          
          // Открывать внешние ссылки в браузере по умолчанию
          win.webContents.setWindowOpenHandler(({ url }) => {
            require('electron').shell.openExternal(url);
            return { action: 'deny' };
          });
        }
        
        app.whenReady().then(createWindow);
        
        app.on('window-all-closed', () => {
          if (process.platform !== 'darwin') {
            app.quit();
          }
        });
        
        app.on('activate', () => {
          if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
          }
        });
        EOF
        
        cat > "$APP_DIR/package.json" << 'EOF'
        {
          "name": "${name}",
          "version": "1.0.0",
          "main": "main.js"
        }
        EOF
        
        # Запуск приложения
        cd "$APP_DIR"
        exec ${pkgs.electron}/bin/electron . "$@"
      '';

      desktopItem = pkgs.makeDesktopItem {
        name = name;
        desktopName = displayName;
        exec = "${electronApp}/bin/${name}";
        icon = icon;
        categories = ["Network"];
        comment = "${displayName} web application";
        startupNotify = true;
        startupWMClass = name;
      };

    in pkgs.symlinkJoin {
      name = "${name}-app";
      paths = [ electronApp desktopItem ];
    };

  # WhatsApp Web
  whatsappWeb = makeElectronApp {
    name = "whatsapp-web-electron";
    displayName = "WhatsApp Web";
    url = "https://web.whatsapp.com/";
    icon = "whatsapp";
    userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
  };

  # Telegram Web
  telegramWeb = makeElectronApp {
    name = "telegram-web-electron";
    displayName = "Telegram Web";
    url = "https://web.telegram.org/z/";
    icon = "telegram";
  };

  # YouTube Music
  youtubeMusicWeb = makeElectronApp {
    name = "youtube-music-electron";
    displayName = "YouTube Music";
    url = "https://music.youtube.com/";
    icon = "youtube";
  };

  # Discord Web
  discordWeb = makeElectronApp {
    name = "discord-web-electron";
    displayName = "Discord Web";
    url = "https://discord.com/app";
    icon = "discord";
  };

  # Gmail
  gmailWeb = makeElectronApp {
    name = "gmail-electron";
    displayName = "Gmail";
    url = "https://mail.google.com/";
    icon = "gmail";
  };

in {
  home.packages = [
    whatsappWeb
    telegramWeb
    youtubeMusicWeb
    discordWeb
    gmailWeb
  ];

  # Создать директорию для electron приложений
  home.file.".local/share/electron-apps/.keep".text = "";
}