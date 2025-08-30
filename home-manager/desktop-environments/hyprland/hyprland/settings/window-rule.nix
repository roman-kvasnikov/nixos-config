{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Browser types
      "tag +chromium-based-browser, class:([cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable)"
      "tile, tag:chromium-based-browser"
      "opacity 1 0.97, tag:chromium-based-browser"

      "opacity 1.0 1.0, initialTitle:(youtube\\.com_/|app\\.zoom\\.us_/wc/home)"
    ];

    windowrulev2 = [
      "tag +calculator, class:(org.gnome.Calendar)"
      "size 768 600, tag:calculator"
      "center, tag:calculator"

      "tag +wofi, class:(wofi)"
      "size 600 600, tag:wofi"
      "center, tag:wofi"
    ];
  };
}
