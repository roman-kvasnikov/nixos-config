{pkgs, ...}: {
  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1"; # Firefox поддержка Wayland
      NIXOS_OZONE_WL = "1"; # Chromium/Electron apps поддержка Wayland

      # Hyprland specific
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";

      MALLOC_CHECK_ = "0"; # Отключаем проверку памяти для производительности
    };

    systemPackages = with pkgs; [
      # Hyprland specific
      hypridle # Idle detection
      hyprlock # Screen locker
      hyprpaper # Wallpaper manager
      hyprpicker # Color picker
      hyprpolkitagent # Polkit agent
      hyprshot # Screenshot tool
      hyprsysteminfo # System info

      # Hyprland utilities
      waybar # Status bar
      wofi # Application launcher
      mako # Notification daemon
      wlogout # Logout menu

      # System utilities
      libnotify # Notification daemon
      pamixer # Volume control
      brightnessctl # Brightness control
    ];
  };
}
