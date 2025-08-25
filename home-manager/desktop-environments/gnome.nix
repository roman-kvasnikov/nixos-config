{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  # =============================================================================
  # GNOME DESKTOP ENVIRONMENT - HOME MANAGER
  # =============================================================================

  # =============================================================================
  # DCONF НАСТРОЙКИ GNOME
  # =============================================================================

  imports = [
    ../modules/dconf # Полная dconf конфигурация GNOME
  ];

  # =============================================================================
  # GTK НАСТРОЙКИ И BOOKMARKS
  # =============================================================================

  gtk.gtk3 = {
    bookmarks = [
      "file:///"
      "file://${config.xdg.dataHome} .local"
      "file://${config.xdg.configHome}"
      "file://${config.xdg.userDirs.download}"
    ];
  };

  # =============================================================================
  # STYLIX ИНТЕГРАЦИЯ С GNOME
  # =============================================================================

  stylix = {
    enable = true;

    # Wallpaper и цветовая схема
    image = "${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png";
    imageScalingMode = "fill";
    polarity = "dark";

    # Шрифты для GNOME
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.ubuntu;
        name = "Ubuntu";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.ubuntu-sans;
        name = "Ubuntu Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.ubuntu-mono;
        name = "Ubuntu Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    # Прозрачность элементов
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 0.9;
      terminal = 0.95;
    };

    # Включить GNOME интеграцию
    targets = {
      gnome.enable = true;
      kitty.enable = false; # Отдельно настроим в модуле kitty
      vscode.enable = false; # Отдельно настроим в модуле vscode
    };
  };

  # =============================================================================
  # XDG НАСТРОЙКИ ДЛЯ GNOME
  # =============================================================================

  xdg = {
    enable = true;

    # MIME ассоциации для GNOME
    mimeApps = {
      enable = true;

      defaultApplications = {
        # Веб-браузер
        "text/html" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];
        "x-scheme-handler/about" = ["brave-browser.desktop"];
        "x-scheme-handler/unknown" = ["brave-browser.desktop"];

        # Файловый менеджер
        "inode/directory" = ["org.gnome.Nautilus.desktop"];

        # Изображения
        "image/jpeg" = ["org.gnome.eog.desktop"];
        "image/png" = ["org.gnome.eog.desktop"];
        "image/gif" = ["org.gnome.eog.desktop"];
        "image/webp" = ["org.gnome.eog.desktop"];

        # Видео
        "video/mp4" = ["org.gnome.Totem.desktop"];
        "video/x-msvideo" = ["org.gnome.Totem.desktop"];
        "video/quicktime" = ["org.gnome.Totem.desktop"];

        # Аудио
        "audio/mpeg" = ["org.gnome.Totem.desktop"];
        "audio/ogg" = ["org.gnome.Totem.desktop"];
        "audio/x-wav" = ["org.gnome.Totem.desktop"];

        # Текстовые файлы
        "text/plain" = ["org.gnome.TextEditor.desktop"];
        "text/markdown" = ["org.gnome.TextEditor.desktop"];

        # PDF
        "application/pdf" = ["org.gnome.Evince.desktop"];

        # Архивы
        "application/zip" = ["org.gnome.FileRoller.desktop"];
        "application/x-tar" = ["org.gnome.FileRoller.desktop"];
        "application/gzip" = ["org.gnome.FileRoller.desktop"];
      };
    };

    # Пользовательские директории
    userDirs = {
      enable = true;
      createDirectories = true;

      # Стандартные GNOME директории
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  # =============================================================================
  # GNOME ПРИЛОЖЕНИЯ И PACKAGES
  # =============================================================================

  home.packages = with pkgs; [
    # GNOME Core приложения (если нужны)
    gnome-tweaks # Дополнительные настройки GNOME
    dconf-editor # Редактор настроек

    # GNOME расширения
    gnomeExtensions.dash-to-dock
    gnomeExtensions.auto-move-windows
    gnomeExtensions.just-perfection
    gnomeExtensions.caffeine
    gnomeExtensions.blur-my-shell
    gnomeExtensions.clipboard-history
    gnomeExtensions.search-light
    gnomeExtensions.bitcoin-markets

    # GTK темы и иконки (если нужны дополнительные)
    # adwaita-icon-theme
    # gnome-icon-theme
  ];

  # =============================================================================
  # ENVIRONMENT VARIABLES ДЛЯ GNOME
  # =============================================================================

  home.sessionVariables = {
    # GNOME/GTK настройки
    GTK_THEME = "default-dark";

    # Wayland настройки для GNOME приложений
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11";

    # Масштабирование для HiDPI (если нужно)
    # GDK_SCALE = "1.25";
    # GDK_DPI_SCALE = "0.8";
  };

  # =============================================================================
  # SERVICES ДЛЯ GNOME ИНТЕГРАЦИИ
  # =============================================================================

  services = {
    # GNOME Keyring интеграция
    gnome-keyring = {
      enable = true;
      components = ["pkcs11" "secrets" "ssh"];
    };

    # Уведомления через GNOME
    # mako.enable = false; # Отключаем для GNOME
    # dunst.enable = false; # Отключаем для GNOME
  };

  # =============================================================================
  # GNOME SHELL РАСШИРЕНИЯ (CUSTOM)
  # =============================================================================

  # Кастомные расширения устанавливаются через xdg.dataFile
  # Пример для xray-toggle расширения:
  # xdg.dataFile = {
  #   "gnome-shell/extensions/xray-toggle@romank-nixos/extension.js" = {
  #     source = ../modules/xray-toggle-extension/extension.js;
  #   };
  #   "gnome-shell/extensions/xray-toggle@romank-nixos/metadata.json" = {
  #     source = ../modules/xray-toggle-extension/metadata.json;
  #   };
  # };

  # =============================================================================
  # КОММЕНТАРИИ ДЛЯ БУДУЩИХ РАСШИРЕНИЙ
  # =============================================================================

  # Этот файл содержит все настройки Home Manager, специфичные для GNOME:
  # - dconf настройки (через import модулей dconf)
  # - GTK темы и bookmarks
  # - Stylix интеграция с GNOME
  # - XDG MIME ассоциации и пользовательские директории
  # - GNOME приложения и расширения
  # - Environment variables для GTK/Wayland
  # - GNOME services (keyring, уведомления)
  # - Кастомные GNOME Shell расширения
  #
  # Для создания альтернативного окружения (например, Hyprland):
  # 1. Создать файл hyprland.nix по аналогии
  # 2. Заменить dconf на Hyprland-специфичные настройки
  # 3. Добавить Waybar, Wofi, и другие Hyprland компоненты
  # 4. Настроить соответствующие MIME ассоциации
}
