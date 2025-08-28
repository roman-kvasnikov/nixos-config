{
  pkgs,
  lib,
  ...
}: {
  services = {
    # GDM display manager с Wayland
    displayManager.gdm = {
      enable = true;
      wayland = true; # Включить Wayland по умолчанию
      autoSuspend = false; # Для single-user системы
    };

    # GNOME desktop environment
    desktopManager.gnome.enable = true;

    # GNOME system services
    gnome = lib.mkForce {
      gnome-keyring.enable = false; # Используем KeePassXC
      # Оптимизация для производительности
      at-spi2-core.enable = true;
    };

    # Геолокация для часовых поясов и функций GNOME
    geoclue2.enable = true;

    # Энергосбережение для ноутбуков (интеграция с GNOME)
    power-profiles-daemon.enable = true;

    # Автоматическое монтирование USB (для Files/Nautilus)
    udisks2.enable = true;

    # Современная индексация файлов для GNOME Search
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };
  };
}
