{
  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false; # Если включено withUWSM, то тут false

    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";
      "$browser" = "brave";
    };
  };

  imports = [
    ./settings
  ];
}
