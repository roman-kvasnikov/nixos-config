{
  wayland.windowManager.hyprland.settings = {
    # Browser types
    windowrule = [
      {
        tag = "chromium-based-browser";
        class = "([cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable)";
      }
      {
        tile = true;
        tag = "chromium-based-browser";
      }
      {
        opacity = "1 0.97";
        tag = "chromium-based-browser";
      }
      {
        opacity = "1.0 1.0";
        initialTitle = "(youtube\\.com_/|app\\.zoom\\.us_/wc/home)";
      }
    ];
  };
}
