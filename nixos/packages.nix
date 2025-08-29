{pkgs, ...}: {
  nixpkgs.config = {
    allowUnfree = true;

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

      # SSH утилиты
      # ssh-to-age # Конвертация SSH ключей в age
      ssh-copy-id # Копирование ключей на сервер
      # ssh-audit # Аудит SSH безопасности
      openssh # SSH клиент
      # sshfs # Монтирование по SSH
      # rsync # Синхронизация по SSH
      # mosh # Mobile shell (альтернатива SSH)

      # Архиваторы (системные зависимости)
      gzip
      p7zip
      zip
      unzip
      unrar

      # Форматирование Nix кода (перенести в home-manager)
      # inputs.alejandra.defaultPackage.${system}

      # Системная диагностика
      # pciutils
      # usbutils
      # lshw

      # Безопасность
      # gnupg
      libsecret

      # Файловая система
      ntfs3g
      exfat

      # Мониторинг (для системных служб)
      htop
      btop
    ];
  };
}
