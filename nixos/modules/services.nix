{
  pkgs,
  lib,
  user,
  ...
}: {
  services = {
    # PipeWire audio subsystem
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

    # Firmware updates для безопасности
    fwupd.enable = true;

    # Отключить сетевые службы, если не нужны
    avahi.enable = lib.mkForce false; # mDNS/DNS-SD

    # Энергосбережение для ноутбуков
    thermald.enable = lib.mkForce true; # Тепловое управление Intel

    # Автоматическое монтирование USB (для Files/Nautilus)
    udisks2.enable = true;

    # Энергосбережение для ноутбуков
    power-profiles-daemon.enable = true;

    # Геолокация для часовых поясов
    geoclue2.enable = true;

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
