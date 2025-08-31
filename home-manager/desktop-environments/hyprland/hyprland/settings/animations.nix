{
  wayland.windowManager.hyprland.settings = {
    animations = {
      enabled = true;

      # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

      # MODE 1
      # bezier = [
      #   "myBezier, 0.05, 0.9, 0.1, 1.05"
      #   "flatline, 1.0, 1.0, 0, 0"
      #   "flatlinetwo, 0, 0, 1, 1"
      #   "shuff, 0, 0.33, 0.66, 1.0"
      #   "BorderRotation, 0.45, 0, 0.55, 1"
      # ];

      # animation = [
      #   "windows, 1, 3, myBezier"
      #   "windowsIn, 1, 3, myBezier"
      #   "windowsOut, 1, 2, default, popin 80%"
      #   "border, 1, 10, default"
      #   "borderangle, 1, 30, flatlinetwo, loop"
      #   "fade, 1, 4, default"
      #   "workspaces, 1, 3, myBezier"
      #   "specialWorkspace, 1, 2, myBezier, slidevert"
      # ];

      # MODE 2
      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
        "winIn, 0.1, 1.1, 0.1, 1.1"
        "winOut, 0.3, -0.3, 0, 1"
        "liner, 1, 1, 1, 1"
      ];

      animation = [
        "windows, 1, 6, wind, slide"
        "windowsIn, 1, 6, winIn, slide"
        "windowsOut, 1, 5, winOut, slide"
        "windowsMove, 1, 5, wind, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 10, default"
        "workspaces, 1, 5, wind"
      ];
    };
  };
}
