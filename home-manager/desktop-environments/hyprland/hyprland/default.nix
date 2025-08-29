{
  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = true; # Если включено withUWSM, то тут false

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
