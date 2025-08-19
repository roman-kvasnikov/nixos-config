{
  inputs,
  pkgs,
  system,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;
    # Оптимизации для single-user системы
    permittedInsecurePackages = [
      # При необходимости добавить здесь разрешенные небезопасные пакеты
    ];
  };

  environment = {
    # Системные пакеты (только необходимые для работы системы)
    systemPackages = with pkgs; [
      # Управление системой
      home-manager

      # Основные утилиты (должны быть в системе для скриптов)
      curl
      wget
      git
      gh # GitHub CLI
      rsync

      # SSH утилиты
      ssh-to-age # Конвертация SSH ключей в age
      ssh-copy-id # Копирование ключей на сервер
      ssh-audit # Аудит SSH безопасности
      openssh # SSH клиент
      sshfs # Монтирование по SSH
      rsync # Синхронизация по SSH
      mosh # Mobile shell (альтернатива SSH)

      # Архиваторы (системные зависимости)
      gzip
      p7zip
      zip
      unzip
      unrar

      # Форматирование Nix кода
      inputs.alejandra.defaultPackage.${system}

      # Системная диагностика
      pciutils
      usbutils
      lshw

      # Безопасность
      gnupg
      libsecret

      # Файловая система
      ntfs3g
      exfat

      # Мониторинг (для системных служб)
      htop
      btop
    ];

    # Минимальные GNOME пакеты (убрать максимально)
    gnome.excludePackages = with pkgs; [
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
  };
}
