{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Fix some dragging issues with XWayland
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

      # Floating windows
      "float, tag:floating-window"
      "center, tag:floating-window"
      "size 800 600, tag:floating-window"

      "tag +floating-window, class:(xdg-desktop-portal-gtk), title:^(Open.*Files?|Save.*Files?|Save.*As|All Files|Save)"
    ];

    windowrulev2 = [
      "float, tag:floating-window"
      "center, tag:floating-window"
      "size 800 600, tag:floating-window"

      "size 500 700, class:(blueberry.py)"
      "size 800 1200, class:(org.pulseaudio.pavucontrol)"
      "size 1280 720, class:(kitty)"

      "tag +floating-window, class:(blueberry.py|org.gnome.Calculator|org.gnome.Calendar|org.pulseaudio.pavucontrol|vlc|kitty)"
    ];
  };
}
