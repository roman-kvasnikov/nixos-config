{
  pkgs,
  lib,
  user,
  ...
}: {
  # =============================================================================
  # GNOME DESKTOP ENVIRONMENT
  # =============================================================================

  # Display Manager и Desktop Environment
  services = {
    # Wayland-based GNOME display manager
    displayManager.gdm = {
      enable = true;
      wayland = true; # Включить Wayland по умолчанию
      autoSuspend = false; # Для single-user системы
    };

    # GNOME Desktop Environment
    desktopManager.gnome.enable = true;

    # Автоматический логин (опционально, закомментирован)
    # displayManager.autoLogin = {
    #   enable = true;
    #   user = user.name;
    # };

    # GNOME системные сервисы
    gnome = lib.mkForce {
      gnome-keyring.enable = false; # Используем KeePassXC
      # Оптимизация для производительности
      at-spi2-core.enable = true;
    };

    # Геолокация для часовых поясов и функций GNOME
    geoclue2.enable = lib.mkForce true;

    # Энергосбережение для ноутбуков (интеграция с GNOME)
    power-profiles-daemon.enable = lib.mkForce true;

    # Автоматическое монтирование USB (для Files/Nautilus)
    udisks2.enable = true;

    # Современная индексация файлов для GNOME Search
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };
  };

  # =============================================================================
  # WAYLAND И ГРАФИЧЕСКАЯ ПОДСИСТЕМА
  # =============================================================================

  environment.sessionVariables = {
    # Wayland настройки для приложений
    MOZ_ENABLE_WAYLAND = "1"; # Firefox поддержка Wayland
    NIXOS_OZONE_WL = "1"; # Chromium/Electron apps поддержка Wayland

    # XDG настройки для Wayland сессии
    XDG_SESSION_TYPE = "wayland";

    # Оптимизации производительности
    MALLOC_CHECK_ = "0"; # Отключаем проверку памяти для производительности
  };

  # =============================================================================
  # АУДИО ПОДСИСТЕМА (PIPEWIRE)
  # =============================================================================

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # Оптимизация для низкой задержки
    wireplumber.enable = true;
  };

  # Отключить PulseAudio полностью (конфликт с PipeWire)
  services.pulseaudio.enable = false;

  # =============================================================================
  # SECURITY И АУТЕНТИФИКАЦИЯ
  # =============================================================================

  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
  };

  # Polkit для работы с правами в GNOME
  security.polkit.enable = true;

  # =============================================================================
  # GNOME PACKAGES OPTIMIZATION
  # =============================================================================

  environment.gnome.excludePackages = with pkgs; [
    # Приложения (заменим на лучшие аналоги в home-manager)
    # gnome-control-center # Control Center (включая Manage Printing)
    gnome-console # Console
    gnome-characters # Редко используется
    gnomeExtensions.order-gnome-shell-extensions # Extensions
    gnome-shell-extensions # Extensions
    gnome-extension-manager # Extensions
    gnome-tour # Тур по Gnome
    gnome-contacts # Контакты
    gnome-music # Музыка
    gnome-photos # Фото
    gnome-software # Центр приложений
    gnome-boxes # Виртуальные машины
    gnome-builder # IDE для разработки
    gnome-font-viewer # Просмотр шрифтов
    gnome-terminal # Используем kitty
    gnome-tweaks # Настройки Gnome

    file-roller # Есть лучшие архиваторы
    simple-scan # Редко нужно
    seahorse # Используем KeePassXC
    epiphany # Используем Brave
    geary # Веб-клиенты лучше
    evolution # Thunderbird лучше
    totem # VLC лучше

    # Игры (не нужны для рабочего компьютера)
    aisleriot
    gnome-chess
    gnome-mahjongg
    iagno
    tali
    hitori
    atomix
    four-in-a-row
    gnome-robots
    gnome-sudoku
    gnome-taquin
    gnome-tetravex
    lightsoff

    # Документация (не нужна в GUI)
    yelp
    gnome-user-docs

    # Дополнительные приложения
    cheese # Камера - редко используется
    baobab # Анализатор дисков - есть альтернативы
  ];

  # =============================================================================
  # XDG И GTK НАСТРОЙКИ
  # =============================================================================

  # XDG портал для интеграции приложений с системой
  xdg.portal = {
    enable = true;
    wlr.enable = false; # Отключаем wlroots портал для GNOME
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # GNOME портал для файловых диалогов, etc.
    ];
    config = {
      common = {
        default = ["gnome"];
      };
      gnome = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gnome"];
        "org.freedesktop.impl.portal.AppChooser" = ["gnome"];
        "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
        "org.freedesktop.impl.portal.Wallpaper" = ["gnome"];
      };
    };
  };

  # Включить поддержку OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      # VAAPI и VDPAU для аппаратного ускорения видео
      libvdpau-va-gl
      vaapiVdpau
      libva
      # Mesa драйвера
      mesa.drivers
    ];
  };

  # =============================================================================
  # КОММЕНТАРИИ ДЛЯ БУДУЩИХ РАСШИРЕНИЙ
  # =============================================================================

  # Этот файл содержит все настройки, специфичные для GNOME desktop environment:
  # - GDM display manager с Wayland
  # - GNOME desktop environment
  # - PipeWire audio subsystem
  # - Wayland session variables
  # - XDG portals для интеграции приложений
  # - OpenGL hardware acceleration
  # - GNOME-specific security settings (PAM, polkit)
  # - Optimization: excluded unnecessary GNOME packages
  #
  # Для создания альтернативного окружения (например, Hyprland):
  # 1. Создать файл hyprland.nix по аналогии
  # 2. Включить нужное окружение в configuration.nix
  # 3. Отключить неиспользуемое окружение
}
