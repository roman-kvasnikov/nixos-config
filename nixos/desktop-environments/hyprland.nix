{
  pkgs,
  lib,
  user,
  ...
}: {
  # =============================================================================
  # HYPRLAND DESKTOP ENVIRONMENT
  # =============================================================================

  # Display Manager для Hyprland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
    settings = {
      Theme = {
        Current = "breeze";
        CursorTheme = "breeze_cursors";
      };
    };
  };

  # Hyprland Window Manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # =============================================================================
  # WAYLAND И ГРАФИЧЕСКАЯ ПОДСИСТЕМА
  # =============================================================================

  environment.sessionVariables = {
    # Wayland настройки для приложений
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";

    # Hyprland specific
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";

    # NVIDIA specific (если нужно)
    # WLR_NO_HARDWARE_CURSORS = "1";
    # LIBVA_DRIVER_NAME = "nvidia";
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
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;

  # =============================================================================
  # XDG PORTALS ДЛЯ HYPRLAND
  # =============================================================================

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = ["hyprland" "gtk"];
      };
      hyprland = {
        default = ["hyprland" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
      };
    };
  };

  # =============================================================================
  # ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ ДЛЯ HYPRLAND
  # =============================================================================

  environment.systemPackages = with pkgs; [
    # Notification daemon
    mako
    # Application launcher
    wofi
    rofi-wayland
    # Status bar
    waybar
    # Wallpaper
    swww
    hyprpaper
    # Screen locker
    swaylock-effects
    # Screen capture
    grim
    slurp
    wf-recorder
    # File manager
    thunar
    # Additional utilities
    brightnessctl
    pamixer
    playerctl
    wl-clipboard
    # Terminal
    kitty
  ];

  # =============================================================================
  # SECURITY И АУТЕНТИФИКАЦИЯ
  # =============================================================================

  security.pam.services.swaylock = {};
  security.polkit.enable = true;

  # =============================================================================
  # GRAPHICS
  # =============================================================================

  hardware = {
    graphics = {
      enable = true;
    };
  };
  # =============================================================================
  # ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ
  # =============================================================================

  # Fonts для системы
  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu
    noto-fonts
    noto-fonts-emoji
  ];
}
