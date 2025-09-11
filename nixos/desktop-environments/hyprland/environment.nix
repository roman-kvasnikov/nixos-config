{pkgs, ...}: {
  environment = {
    sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
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
