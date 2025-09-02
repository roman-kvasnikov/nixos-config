{lib, ...}: {
  # Monitor settings with switcher is in the display-switcher module

  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkDefault [
      ", preferred, auto, 1"
    ];
  };
}
