{pkgs, ...}: {
  nixpkgs.config = {
    allowUnfree = true;
    # allowUnsupportedSystem = true;

    permittedInsecurePackages = [];
  };

  environment.systemPackages = with pkgs; [
    # Управление системой
    home-manager

    # Основные утилиты (должны быть в системе для скриптов)
    curl
    wget
    git
    gh # GitHub CLI
    lazygit # GitHub CLI
    killall
    lm_sensors # Hardware monitoring
    dig

    # SSH утилиты
    ssh-copy-id
    openssh
    rsync

    # Архиваторы (системные зависимости)
    gzip
    p7zip
    zip
    unzip
    unrar

    # Безопасность
    libsecret

    # Мониторинг
    htop
    btop
  ];
}
