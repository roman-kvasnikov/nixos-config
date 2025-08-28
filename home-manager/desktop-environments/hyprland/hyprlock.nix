{inputs, ...}: {
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          monitor = "all";
          path = "${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png";
          color = "rgba(25, 20, 20, 1.0)";

          # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
          blur_passes = 3; # 0 disables blurring
          blur_size = 7;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];

      label = [
        {
          monitor = "all";
          text = "$USER";
          color = "rgba(240, 240, 240, 1.0)";
          font_family = "Fira Code Semibold";
          font_size = 12;
          position = "-10, -10";
          halign = "right";
          valign = "top";
          shadow_passes = 5;
          shadow_size = 10;
        }
        {
          monitor = "all";
          text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color = "rgba(240, 240, 240, 1.0)";
          font_family = "Fira Code Bold";
          font_size = 100;
          position = "0, 200";
          halign = "center";
          valign = "center";
          shadow_passes = 5;
          shadow_size = 10;
        }
        {
          monitor = "all";
          text = "cmd[update:1000] echo \"$(date +\"%A, %d %B %Y\")\"";
          color = "rgba(240, 240, 240, 1.0)";
          font_family = "Fira Code Regular";
          font_size = 26;
          position = "0, 100";
          halign = "center";
          valign = "center";
          shadow_passes = 5;
          shadow_size = 10;
        }
      ];

      input-field = [
        {
          monitor = "all";
          size = "326, 50";
          outline_thickness = 3;
          dots_size = 1; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = false;
          dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
          outer_color = "rgb(151515)";
          inner_color = "rgb(200, 200, 200)";
          font_color = "rgb(10, 10, 10)";
          fade_on_empty = true;
          fade_timeout = 1000; # Milliseconds before fade_on_empty is triggered.
          placeholder_text = "<i>Input Password...</i>"; # Text rendered in the input box when it's empty.
          hide_input = false;
          rounding = -1; # -1 means complete rounding (circle/oval)
          check_color = "rgb(204, 136, 34)";
          fail_color = "rgb(204, 34, 34)"; # if authentication failed, changes outer_color and fail message color
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # can be set to empty
          fail_transition = 300; # transition time in ms between normal outer_color and fail_color
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1; # when both locks are active. -1 means don't change outer color (same for above)
          invert_numlock = false; # change color if numlock is off
          swap_font_color = false; # see below

          position = "0, -200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
