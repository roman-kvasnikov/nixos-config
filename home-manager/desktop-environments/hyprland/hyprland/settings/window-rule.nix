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
      "tag +blueberry, class:(blueberry.py)"
      "float, tag:blueberry"
      "size 500 700, tag:blueberry"
      "center, tag:blueberry"

      "tag +calculator, class:(org.gnome.Calculator)"
      "float, tag:calculator"
      "center, tag:calculator"

      "tag +calendar, class:(org.gnome.Calendar)"
      "float, tag:calendar"
      "size 768 600, tag:calendar"
      "center, tag:calendar"

      "tag +pavucontrol, class:(org.pulseaudio.pavucontrol)"
      "float, tag:pavucontrol"
      "size 800 800, tag:pavucontrol"
      "center, tag:pavucontrol"
    ];
  };
}
