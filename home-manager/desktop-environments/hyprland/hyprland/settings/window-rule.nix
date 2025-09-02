{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Fix some dragging issues with XWayland
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];

    windowrulev2 = [
      # Floating windows
      "float, tag:floating-window"
      "center, tag:floating-window"

      "tag +floating-window, class:(blueberry.py|org.gnome.Calculator|org.gnome.Calendar|org.pulseaudio.pavucontrol|vlc|kitty|dev.warp.Warp|electrum)"
      "tag +floating-window, class:(xdg-desktop-portal-gtk), title:^(Open.*Files?|Save.*Files?|Save.*As|All Files|Save)"

      "size 500 700, class:(blueberry.py)"
      "size 800 1200, class:(org.pulseaudio.pavucontrol)"
      "size 50% 50%, class:(kitty|dev.warp.Warp)"

      # Brave browser
      "workspace 1, class:(brave-browser)" # Move brave browser to workspace 1
      "opacity 1.0 override, class:(brave-browser)" # Set opacity of brave browser to 1.0

      # Cursor
      "workspace 4, class:(cursor)" # Move cursor to workspace 4

      # KeepassXC
      "workspace 5, class:(org.keepassxc.KeePassXC)" # Move keepassxc to workspace 5

      # Kitty and Warp
      "opacity 0.8 override, class:(kitty|dev.warp.Warp)" # Set opacity for kitty and warp to 0.8

      # VLC
      "idleinhibit fullscreen, class:(vlc)" # Inhibit idle fullscreen for vlc
    ];
  };
}
