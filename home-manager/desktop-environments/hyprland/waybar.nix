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
      * {
        border: none;
        border-radius: 0;
        font-family: "Ubuntu Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(26, 27, 38, 0.9);
        border-bottom: 2px solid rgba(137, 180, 250, 0.6);
        color: #cdd6f4;
        transition-property: background-color;
        transition-duration: 0.3s;
      }

      /* =================================================================
         WORKSPACES
         ================================================================= */

      #workspaces {
        margin: 0 6px;
        padding: 0 4px;
      }

      #workspaces button {
        padding: 4px 8px;
        background-color: transparent;
        color: #7f849c;
        border-radius: 4px;
        margin: 2px;
        transition: all 0.2s ease;
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.1);
        color: #89b4fa;
      }

      #workspaces button.active {
        background-color: #89b4fa;
        color: #1e1e2e;
        font-weight: bold;
      }

      #workspaces button.urgent {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation: blink 1s linear infinite;
      }

      /* =================================================================
         GROUPS
         ================================================================= */

      .modules-left {
        padding-left: 8px;
      }

      .modules-center {
        padding: 0 8px;
      }

      .modules-right {
        padding-right: 8px;
      }

      /* =================================================================
         COMMON MODULE STYLES
         ================================================================= */

      #tray, #network, #bluetooth, #pulseaudio, #battery, #clock,
      #cpu, #memory, #disk, #temperature, #language,
      #custom-weather, #custom-updates, #custom-swaync, #custom-vpn-home-l2tp,
      #custom-btc-rate, #custom-gala-rate, #custom-trump-rate {
        padding: 4px 8px;
        margin: 0 2px;
        border-radius: 4px;
        background-color: rgba(49, 50, 68, 0.7);
        color: #cdd6f4;
        transition: all 0.2s ease;
      }

      #custom-delimeter {
        color: #45475a;
        padding: 0 4px;
        font-weight: bold;
      }

      /* =================================================================
         SPECIFIC MODULE STYLES
         ================================================================= */

      #clock {
        font-weight: bold;
        background-color: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation: blink 0.5s linear infinite alternate;
      }

      #battery.warning:not(.charging) {
        background-color: #f9e2af;
        color: #1e1e2e;
      }

      #cpu.warning {
        background-color: #f9e2af;
        color: #1e1e2e;
      }

      #cpu.critical {
        background-color: #f38ba8;
        color: #1e1e2e;
      }

      #memory.warning {
        background-color: #f9e2af;
        color: #1e1e2e;
      }

      #memory.critical {
        background-color: #f38ba8;
        color: #1e1e2e;
      }

      #disk.warning {
        background-color: #f9e2af;
        color: #1e1e2e;
      }

      #disk.critical {
        background-color: #f38ba8;
        color: #1e1e2e;
      }

      /* =================================================================
         CRYPTO RATES
         ================================================================= */

      #custom-btc-rate, #custom-gala-rate, #custom-trump-rate {
        font-weight: bold;
        background-color: rgba(166, 227, 161, 0.2);
      }

      /* =================================================================
         CONNECTIVITY
         ================================================================= */

      #network.disconnected {
        background-color: #f38ba8;
        color: #1e1e2e;
      }

      #bluetooth.off {
        background-color: rgba(69, 71, 90, 0.7);
        color: #6c7086;
      }

      #pulseaudio.muted {
        background-color: rgba(69, 71, 90, 0.7);
        color: #6c7086;
      }

      /* =================================================================
         ANIMATIONS
         ================================================================= */

      @keyframes blink {
        to {
          background-color: rgba(243, 139, 168, 0.5);
        }
      }

      /* =================================================================
         HOVER EFFECTS
         ================================================================= */

      #tray:hover, #network:hover, #bluetooth:hover, #pulseaudio:hover,
      #battery:hover, #cpu:hover, #memory:hover, #disk:hover,
      #custom-weather:hover, #custom-updates:hover, #custom-swaync:hover,
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
