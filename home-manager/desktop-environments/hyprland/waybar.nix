{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [
          "hyprland/workspaces"
          "tray"
          "group/crypto-rates"
        ];

        modules-center = [
          "custom/weather"
          "custom/delimeter"
          "clock"
          "custom/delimeter"
        ];

        modules-right = [
          "group/hardware"
          "custom/delimeter"
          "hyprland/language"
          "custom/delimeter"
          "custom/updates"
          "custom/delimeter"
          "network"
          "custom/vpn-home-l2tp"
          "bluetooth"
          "pulseaudio"
          "custom/delimeter"
          "battery"
        ];

        # =================================================================
        # CUSTOM MODULES
        # =================================================================

        "custom/delimeter" = {
          format = "|";
          tooltip = false;
        };

        # =================================================================
        # HYPRLAND WORKSPACES
        # =================================================================

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
          persistent-workspaces = {
            "*" = [1 2 3 4 5];
          };
        };

        # =================================================================
        # SYSTEM TRAY
        # =================================================================

        tray = {
          icon-size = 20;
          spacing = 10;
        };

        # =================================================================
        # CRYPTO RATES GROUP
        # =================================================================

        "group/crypto-rates" = {
          orientation = "horizontal";
          modules = [
            "custom/btc-rate"
            "custom/gala-rate"
          ];
        };

        "custom/btc-rate" = {
          format = "   {}{icon}";
          format-icons = {
            up = " ";
            down = " ";
            same = " ";
          };
          interval = 300;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c BTC -r 0";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/BTC/USDT'";
          tooltip = false;
        };

        "custom/gala-rate" = {
          format = "   {}{icon}";
          format-icons = {
            up = " ";
            down = " ";
            same = " ";
          };
          interval = 300;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c GALA -r 5";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/GALA/USDT'";
          tooltip = false;
        };

        "custom/trump-rate" = {
          format = "   {}{icon}";
          format-icons = {
            up = " ";
            down = " ";
            same = " ";
          };
          interval = 10;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c TRUMP -r 5";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/TRUMP/USDT'";
          tooltip = false;
        };

        # =================================================================
        # WEATHER & TIME
        # =================================================================

        "custom/weather" = {
          format = "{}";
          interval = 3600;
          exec = "curl 'wttr.in/?format=%c+%t&lang=en'";
          tooltip = false;
        };

        clock = {
          interval = 1;
          format = "{:%a, %d %b %Y, %H:%M}";
          on-click-right = "gnome-calendar";
          tooltip = false;
        };

        # =================================================================
        # NETWORK & CONNECTIVITY
        # =================================================================

        network = {
          format-wifi = "{icon}";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format-disconnected = "󰤭";
          format-disabled = "󰤭";
          tooltip = false;
          on-click = "kitty -e nmtui-connect";
          on-click-right = "nm-connection-editor";
        };

        "custom/vpn-home-l2tp" = {
          format = "";
          interval = 1;
          exec = "bash ~/.config/waybar/scripts/vpn-home-l2tp/is_connected.sh";
          on-click = "bash ~/.config/waybar/scripts/vpn-home-l2tp/toggle_connection.sh";
          return-type = "json";
          tooltip-format = "Home L2TP VPN";
        };

        bluetooth = {
          format-connected = "󰂯";
          format-on = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          tooltip = false;
          on-click-right = "blueman-manager";
        };

        # =================================================================
        # AUDIO
        # =================================================================

        pulseaudio = {
          format = "{icon}";
          format-muted = "";
          format-bluetooth = "{icon} 󰂯";
          format-bluetooth-muted = " 󰂯";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        # =================================================================
        # SYSTEM UPDATES
        # =================================================================

        "custom/updates" = {
          format = " <sup>{0}</sup>";
          escape = true;
          return-type = "json";
          exec = "bash ~/.config/waybar/scripts/updates/updates.sh";
          interval = 900;
          on-click = "kitty -e ~/.config/waybar/scripts/updates/install_updates.sh";
          on-click-right = "kitty -e pacseek";
        };

        # =================================================================
        # HARDWARE GROUP
        # =================================================================

        "group/hardware" = {
          orientation = "horizontal";
          modules = ["cpu" "memory" "disk"];
        };

        temperature = {
          interval = 10;
          hwmon-path = "/sys/class/hwmon/hwmon7/temp1_input";
          critical-threshold = 80;
          format = " {temperatureC}°C";
          tooltip = false;
        };

        cpu = {
          interval = 15;
          format = " {usage}%";
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip = false;
          on-click = "kitty -e btop";
        };

        memory = {
          interval = 15;
          format = " {}%";
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip = false;
          on-click = "kitty -e htop";
        };

        disk = {
          interval = 15;
          format = " {percentage_used}%";
          path = "/home";
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip = false;
        };

        # =================================================================
        # BATTERY
        # =================================================================

        battery = {
          interval = 5;
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-full = "󰁹 {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip = false;
        };

        # =================================================================
        # LANGUAGE & POWER
        # =================================================================

        "hyprland/language" = {
          format = "{}";
          format-en = "ENG";
          format-ru = "RUS";
        };

        "custom/poweroff" = {
          format = "";
          on-click = "wlogout";
          tooltip = false;
        };
      };
    };

    # =================================================================
    # WAYBAR STYLES (CATPPUCCIN THEME)
    # =================================================================

    style = ''
      @define-color black #000000;
      @define-color white #c7c7c7;
      @define-color green #33cc00;
      @define-color yellow #ffff66;
      @define-color red #ff3300;
      @define-color blue #103cfe;

      * {
          font-family: 'Fira Code', 'FontAwesome', 'Material Design Icons', 'Noto Sans', sans-serif;
          font-size: 1.2rem;
          color: @white;
      }

      window#waybar {
          background-color: @black;
          opacity: 0.8;
      }

      #workspaces {
          padding: 0 2px;
      }

      #workspaces button {
          background-color: @black;
          opacity: 0.3;
          border-radius: 0;
          padding: 0 10px;
      }

      #workspaces button.active {
          background: inherit;
          opacity: 1;
          box-shadow: inset 0 0 @black;
          font-weight: bold;
          min-width: 50px;
      }

      #workspaces button:hover {
          background: inherit;
          opacity: 1;
          box-shadow: inset 0 0 @black;
          text-shadow: inherit;
      }

      #custom-delimeter {
          padding: 2px 10px;
      }

      #tray,
      #custom-btc-rate,
      #custom-gala-rate,
      #custom-trump-rate,
      #custom-weather,
      #clock,
      #cpu,
      #memory,
      #disk,
      #language,
      #custom-updates,
      #network,
      #custom-vpn-home-l2tp,
      #bluetooth,
      #pulseaudio,
      #custom-swaync,
      #battery {
          padding: 0 10px;
          margin: 0;
      }

      #bluetooth,
      #custom-updates,
      #custom-swaync {
          padding: 0 6px 0 10px;
      }

      #crypto-rates * {
          font-size: 1rem;
          background-position: 8% 46%;
          background-repeat: no-repeat;
          background-size: 8%;
      }

      #custom-btc-rate {
          background-image: url('/home/romank/.config/waybar/icons/btc-rate/btc-logo.svg');
      }

      #custom-gala-rate {
          background-image: url('/home/romank/.config/waybar/icons/gala-rate/gala-logo.svg');
      }

      #custom-btc-rate.rate-up {
          background-image: url('/home/romank/.config/waybar/icons/btc-rate/btc-logo-green.svg');
      }

      #custom-btc-rate.rate-down {
          background-image: url('/home/romank/.config/waybar/icons/btc-rate/btc-logo-red.svg');
      }

      #custom-gala-rate.rate-up {
          background-image: url('/home/romank/.config/waybar/icons/gala-rate/gala-logo-green.svg');
      }

      #custom-gala-rate.rate-down {
          background-image: url('/home/romank/.config/waybar/icons/gala-rate/gala-logo-red.svg');
      }

      /* COLORS */

      #crypto-rates *.rate-up {
          color: @green;
      }

      #crypto-rates *.rate-down {
          color: @red;
      }

      #crypto-rates *.rate-same {
          color: @white;
      }

      #temperature.warning,
      #cpu.warning,
      #memory.warning,
      #disk.warning {
          color: @yellow;
      }

      #temperature.critical,
      #cpu.critical,
      #memory.critical,
      #disk.critical {
          color: @red;
      }

      #network.wifi,
      #custom-vpn-home-l2tp.connected,
      #bluetooth.connected {
          color: @blue;
      }

      #network.disconnected,
      #bluetooth.off {
          color: @red;
      }


      #custom-updates.green {
          color: @green;
      }

      #custom-updates.yellow {
          color: @yellow;
      }

      #custom-updates.red {
          color: @red;
      }

      #custom-swaync.notification,
      #custom-swaync.dnd-notification,
      #custom-swaync.inhibited-notification,
      #custom-swaync.dnd-inhibited-notification {
          color: @red;
      }

      #battery {
          color: @green;
      }

      #battery.charging,
      #battery.plugged {
          color: @blue;
      }

      #battery.warning:not(.charging) {
          color: @yellow;
      }

      @keyframes blink {
          to {
              color: @black;
          }
      }

      #battery.critical:not(.charging) {
          background-color: @red;
          color: @white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
    '';
  };

  # =============================================================================
  # WAYBAR SCRIPTS DIRECTORY
  # =============================================================================

  home.file.".config/waybar/scripts/.keep".text = "";

  # Note: Waybar scripts should be created manually or via additional modules:
  # - ~/.config/waybar/scripts/crypto-rates.sh
  # - ~/.config/waybar/scripts/vpn-home-l2tp/is_connected.sh
  # - ~/.config/waybar/scripts/vpn-home-l2tp/toggle_connection.sh
  # - ~/.config/waybar/scripts/updates/updates.sh
  # - ~/.config/waybar/scripts/updates/install_updates.sh
}
