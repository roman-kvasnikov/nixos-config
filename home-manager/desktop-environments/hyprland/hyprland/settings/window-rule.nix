{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Workspaces
      "match:class brave-browser, workspace 1"
      "match:class cursor, workspace 4"

      # Floating windows
      "match:tag floating-window, float on"
      "match:tag floating-window, center on"

      # Brave-Browser
      "match:class brave-browser, opacity 1.0 override"

      # Calculator
      "match:class org.gnome.Calculator, tag +floating-window"
      "match:class org.gnome.Calculator, size 50% 50%"

      # Kitty and Warp
      "match:class (kitty|dev.warp.Warp), tag +floating-window"
      "match:class (kitty|dev.warp.Warp), size 50% 50%"
      "match:class (kitty|dev.warp.Warp), opacity 0.8 override"

      # blueberry.py
      "match:class blueberry.py, tag +floating-window"
      "match:class blueberry.py, size 500 700"

      # org.pulseaudio.pavucontrol
      "match:class org.pulseaudio.pavucontrol, tag +floating-window"
      "match:class org.pulseaudio.pavucontrol, size 800 1200"

      # QtPass
      "match:title QtPass, tag +floating-window"
      "match:title QtPass, size 50% 50%"

      # VLC
      "match:class vlc, tag +floating-window"
      "match:class vlc, size 90% 90%"
      "match:class vlc, idle_inhibit fullscreen"
      "match:class vlc, opacity 1.0 override"

      "match:class xdg-desktop-portal-gtk, tag +floating-window"

      "match:title ^(Open.*Files?|Save.*Files?|Save.*As|All Files|Save), tag +floating-window"
    ];
  };
}
