{
  pkgs,
  lib,
  ...
}: {
  environment = {
    # Wayland session variables
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1"; # Firefox поддержка Wayland
      NIXOS_OZONE_WL = "1"; # Chromium/Electron apps поддержка Wayland

      # Hyprland specific
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";

      # Оптимизации производительности
      MALLOC_CHECK_ = "0"; # Отключаем проверку памяти для производительности
    };

    systemPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland

      # Notification daemon
      mako
      # Application launcher
      wofi
      # Status bar
      waybar
      # Wallpaper
      hyprpaper
      # Screen locker
      hyprlock
      hypridle
      # File manager
      nautilus
      # Text editor
      gedit
      # Logout menu
      wlogout
      # System utilities
      brightnessctl # Яркость
      pamixer # Громкость
      playerctl # Медиа управление
    ];
  };
}
