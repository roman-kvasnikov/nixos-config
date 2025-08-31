{
  wayland.windowManager.hyprland.settings = {
    bind =
      [
        "SUPER, Q, killactive" # Kill active window

        # Applications
        "SUPER, RETURN, exec, warp-terminal" # Warp Terminal
        "SUPER SHIFT, RETURN, exec, $terminal"
        "SUPER, B, exec, [workspace 1] $browser"
        "SUPER, R, exec, $menu"
        "SUPER, E, exec, $fileManager"
        "SUPER, C, exec, gnome-calculator" # Gnome Calculator
        "SUPER SHIFT, S, exec, hyprshot -m region" # Hyprshot
        "SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy" # Cliphist

        # Управление окнами
        "SUPER, T, togglefloating,"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"
        "SUPER, F, fullscreen,"

        # Перемещение между окнами
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        # Wlogout
        "SUPER, Escape, exec, wlogout"
      ]
      ++ (
        builtins.concatLists (builtins.genList (
            i: let
              ws = i + 1;
            in [
              "SUPER, code:1${toString i}, workspace, ${toString ws}"
              "SUPER SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

    # Mouse bindings
    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    # Laptop multimedia keys for volume and LCD brightness
    bindel = [
      ",XF86AudioRaiseVolume,  exec, pamixer -i 5"
      ",XF86AudioLowerVolume,  exec, pamixer -d 5"
      ",XF86AudioMute,         exec, pamixer -t"
      ",XF86AudioMicMute,      exec, pamixer -t"
      ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      "SUPER, bracketright, exec, brightnessctl set +5%"
      "SUPER, bracketleft,  exec, brightnessctl set 5%-"
    ];

    # Audio playback
    bindl = [
      ", XF86AudioNext,  exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay,  exec, playerctl play-pause"
      ", XF86AudioPrev,  exec, playerctl previous"
    ];
  };
}
