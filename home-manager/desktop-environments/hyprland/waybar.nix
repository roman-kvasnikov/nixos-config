{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = ["hyprland/workspaces" "hyprland/mode"];
        modules-center = ["hyprland/window"];
        modules-right = ["network" "pulseaudio" "battery" "clock"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "hyprland/window" = {
          max-length = 50;
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-disconnected = "Disconnected ⚠";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
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
