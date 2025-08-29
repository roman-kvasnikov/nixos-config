{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = ["hyprland/workspaces" "tray" "group/crypto-rates"];
        modules-center = ["custom/weather" "custom/delimeter" "clock" "custom/delimeter"];
        modules-right = ["group/hardware" "custom/delimeter" "hyprland/language" "custom/delimeter" "custom/updates" "custom/delimeter" "network" "bluetooth" "pulseaudio" "custom/delimeter" "battery"];

        "custom/delimeter" = {
          format = "|";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          cursor = true;
          on-scroll-up = "hyprctl dispatch workspace r-1";
          on-scroll-down = "hyprctl dispatch workspace r+1";
          on-click = "activate";
          active-only = false;
          all-outputs = true;
          format = "{}";
          format-icons = {
            urgent = "";
            active = "";
            default = "";
          };
        };

        "tray" = {
          icon-size = 20;
          spacing = 10;
        };

        "group/crypto-rates" = {
          orientation = "horizontal";
          modules = [
            "custom/btc-rate"
            "custom/gala-rate"
          ];
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Ubuntu Nerd Font";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.8);
        border-bottom: 3px solid rgba(137, 180, 250, 0.8);
        color: #cdd6f4;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      #workspaces {
        margin: 0 4px;
      }

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #cdd6f4;
        border-bottom: 3px solid transparent;
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.active {
        background-color: #64748b;
        border-bottom: 3px solid #cdd6f4;
      }

      #network, #pulseaudio, #battery, #clock {
        padding: 0 10px;
        margin: 0 3px;
      }

      #clock {
        font-weight: bold;
      }

      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
    '';
  };
}
