{
  pkgs,
  lib,
  user,
  ...
}: {
  services = {
    # github:nixos/nixpkgs/nixos-unstable
    displayManager.gdm = {
      enable = true;
      wayland = true; # Включить Wayland по умолчанию
      autoSuspend = false; # Для single-user системы
    };

    desktopManager.gnome.enable = true;

    # github:nixos/nixpkgs/nixos-25.05
    # xserver = {
    #   enable = true;

    #   displayManager.gdm = {
    #     enable = true;
    #     wayland = true; # Включить Wayland по умолчанию
    #     autoSuspend = false; # Для single-user системы
    #   };

    #   desktopManager.gnome.enable = true;
    # };

    # Автоматический логин для единственного пользователя
    # displayManager.autoLogin = {
    #   enable = true;
    #   user = user.name;
    # };

    # Современные аудио настройки
    pipewire = {
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
    pulseaudio.enable = false;

    # Системные сервисы для single-user
    gnome = lib.mkForce {
      gnome-keyring.enable = false;
      # Оптимизация для производительности
      at-spi2-core.enable = true;
    };

    # VPN сервисы
    xl2tpd.enable = false;
    libreswan = {
      enable = true;

      configSetup = ''
        protostack=netkey
        plutodebug=none
        logfile=/var/log/pluto.log
        dumpdir=/run/pluto
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
        ikev1-policy=accept
      '';
    };

    # Firmware updates для безопасности
    fwupd.enable = true;

    # Автоматическое монтирование USB
    udisks2.enable = true;

    # Современная индексация файлов для GNOME
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };

    # Отключить сетевые службы, если не нужны
    avahi.enable = lib.mkForce false; # mDNS/DNS-SD
    geoclue2.enable = lib.mkForce true; # Геолокация для часовых поясов

    # Энергосбережение для ноутбуков
    power-profiles-daemon.enable = lib.mkForce true;
    thermald.enable = lib.mkForce true; # Тепловое управление Intel

    # Современные сетевые настройки
    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };

    # Современные настройки udev для SSD
    udev.extraRules = ''
      # SSD оптимизации
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="ext4", ATTR{../queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="btrfs", ATTR{../queue/scheduler}="bfq"

      # Отключить NCQ для некоторых SSD (если проблемы)
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/nr_requests}="64"
    '';
  };
}
