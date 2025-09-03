{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    wttrbar
    (callPackage ./packages/waybar-restart/package.nix {inherit pkgs;}) # Waybar Restart
  ];

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        reload_style_on_change = true;
        layer = "top";
        position = "top";
        spacing = 10;
        height = 38;
        # margin-top = 0;
        # margin-left = 0;
        # margin-right = 0;

        modules-left = [
          "hyprland/workspaces"
          "custom/btc-rate"
          "custom/eth-rate"
          "custom/gala-rate"
        ];

        modules-center = [
          "custom/weather"
          "clock"
          "idle_inhibitor"
        ];

        modules-right = [
          "wlr/taskbar"
          "group/hardware"
          "hyprland/language"
          "group/adjustments"
          "battery"
        ];

        # =================================================================
        # WORKSPACES
        # =================================================================

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{}";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        # =================================================================
        # CRYPTO RATES
        # =================================================================

        "custom/btc-rate" = {
          format = "  {}";
          interval = 300;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c BTC -r 0";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/BTC/USDT'";
          tooltip = false;
        };

        "custom/eth-rate" = {
          format = "  {}";
          interval = 300;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c ETH -r 0";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/ETH/USDT'";
          tooltip = false;
        };

        "custom/gala-rate" = {
          format = "  {}";
          interval = 300;
          exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c GALA -r 5";
          return-type = "json";
          on-click = "xdg-open 'https://www.bybit.com/ru-RU/trade/spot/GALA/USDT'";
          tooltip = false;
        };

        # =================================================================
        # WEATHER AND CLOCK
        # =================================================================

        "custom/weather" = {
          format = "{}°C";
          interval = 900;
          exec = "wttrbar --date-format \"%A, %d %B, %Y\" --location Saint-Petersburg --lang ru";
          return-type = "json";
          on-click = "xdg-open 'https://dzen.ru/pogoda/?lat=59.93867493&lon=30.31449318'";
          tooltip = true;
        };

        clock = {
          format = "{:%a %b %d %H:%M}";
          interval = 1;
          on-click = "gnome-calendar";
          tooltip = false;
        };

        # =================================================================
        # MODULES RIGHT
        # =================================================================

        "wlr/taskbar" = {
          format = "{icon}";
          all-outputs = true;
          active-first = true;
          tooltip-format = "{name}";
          on-click = "activate";
          on-click-middle = "close";
          ignore-list = [
            "wofi"
            "kitty"
            "warp-terminal"
            "keepassxc"
          ];
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = true;
          tooltip-format-activated = "Activated";
          tooltip-format-deactivated = "Deactivated";
        };

        # =================================================================
        # HARDWARE GROUP
        # =================================================================

        "group/hardware" = {
          "orientation" = "horizontal";
          "modules" = ["cpu" "memory"];
        };

        "temperature" = {
          "interval" = 10;
          "format" = "{icon} {temperatureC}°C";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
          # "hwmon-path" = "/sys/class/hwmon/hwmon4/temp1_input";
          "critical-threshold" = 80;
          "tooltip" = false;
        };

        "cpu" = {
          "interval" = 10;
          "format" = " {usage}%";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
          "tooltip" = false;
          "on-click" = "kitty -e btop";
        };

        "memory" = {
          "interval" = 10;
          "format" = " {}%";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
          "tooltip" = false;
          "on-click" = "kitty -e htop";
        };

        "disk" = {
          "interval" = 10;
          "format" = " {percentage_used}%";
          "path" = "/home";
          "states" = {
            "warning" = 70;
            "critical" = 90;
          };
          "tooltip" = false;
        };

        # =================================================================
        # LANGUAGE
        # =================================================================

        "hyprland/language" = {
          format-en = "🇺🇸 en";
          format-ru = "🇷🇺 ru";
          min-length = 4;
          tooltip = false;
        };

        # =================================================================
        # ADJUSTMENTS GROUP
        # =================================================================

        "group/adjustments" = {
          orientation = "horizontal";
          modules = ["network" "bluetooth" "pulseaudio" "backlight"];
        };

        network = {
          format-wifi = "{icon}";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format-disconnected = "󰤭";
          format-disabled = "󰤭";
          tooltip = true;
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) 󰤨";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          on-click = "kitty -e nmtui-connect";
          on-click-right = "kitty -e nmtui";
        };

        bluetooth = {
          format-connected = "";
          format-on = "";
          format-off = "󰂲";
          format-disabled = "󰂲";
          tooltip = true;
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "blueberry";
        };

        "pulseaudio" = {
          format = "{icon}";
          format-muted = "";
          format-bluetooth = "{icon} ";
          format-bluetooth-muted = " ";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              ""
              ""
            ];
          };
          "on-scroll-up" = "pamixer --increase 5";
          "on-scroll-down" = "pamixer --decrease 5";
          "on-click" = "pamixer --toggle-mute";
          "on-click-right" = "pavucontrol";
          tooltip = true;
          tooltip-format = "Volume: {volume}%";
        };

        "backlight" = {
          device = "intel_backlight";
          format = "{icon}";
          scroll-step = 5;
          format-icons = ["󱩎" "󱩑" "󱩓" "󱩕" "󰛨"];
          tooltip = true;
          tooltip-format = "Brightness: {percent}%";
        };

        "backlight-old" = {
          device = "intel_backlight";
          format = "{icon}";
          scroll-step = 5;
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = true;
          tooltip-format = "Brightness: {percent}%";
        };

        # =================================================================
        # BATTERY
        # =================================================================

        "battery" = {
          interval = 5;
          bat = "BAT0";
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-full = " {capacity}%";
          format-charging = " {capacity}%";
          format-icons = ["" "" "" "" ""];
          tooltip = false;
        };
      };
    };

    style = ''
      @define-color black #000000;
      @define-color white #c7c7c7;
      @define-color green #33FF00;
      @define-color yellow #FFFF33;
      @define-color red #ff3300;
      @define-color blue #1E90FF;
      @define-color border-color rgba(255, 255, 255, 0.8);

      * {
      	border: none;
      	border-radius: 0;
      	min-height: 0;

      	font-size: 18px;
      	color: @white;
      }

      .modules-left {
      	margin-left: 8px;
      }

      .modules-right {
      	margin-right: 8px;
      }

      .modules-left #workspaces button {
        border-bottom: 0px;
      }
      .modules-left #workspaces button.focused,
      .modules-left #workspaces button.active {
        border-bottom: 0px;
      }
      .modules-center #workspaces button {
        border-bottom: 0px;
      }
      .modules-center #workspaces button.focused,
      .modules-center #workspaces button.active {
        border-bottom: 0px;
      }
      .modules-right #workspaces button {
        border-bottom: 0px;
      }
      .modules-right #workspaces button.focused,
      .modules-right #workspaces button.active {
        border-bottom: 0px;
      }

      window#waybar {
      	background-color: rgba(0, 0, 0, 0.5);
      	opacity: 1;
      }

      #workspaces,
      #custom-btc-rate,
      #custom-eth-rate,
      #custom-gala-rate,
      #custom-weather,
      #clock,
      #taskbar,
      #idle_inhibitor,
      #hardware,
      #language,
      #adjustments,
      #battery {
      	margin-top: 4px;
      	margin-bottom: 4px;
      	padding-left: 10px;
      	padding-right: 10px;
      	border-radius: 8px;
      	border: 1px solid @border-color;
      	background-color: rgba(0, 0, 0, 0.6);
      }

      tooltip {
      	background-color: rgba(0, 0, 0, 0.6);
      	color: @white;
      	opacity: 1;
      	border: 3px solid @border-color;
      	border-radius: 8px;
      	padding: 5px 15px;
      }

       #workspaces {
         padding-left: 0px;
         padding-right: 0px;
       }

      #workspaces button {
        font-weight: normal;
        transition: none;
        padding: 2px 10px 0 10px;
        margin: 0;
        min-width: 15px;
        transition: background-color 0.3s ease;
      }

      #workspaces button.active {
        font-weight: bold;
        padding: 2px 20px 0 20px;
        border-radius: 8px;
        background-color: rgba(255, 255, 255, 0.5);
      }

      #workspaces button:hover,
      #workspaces button.empty:hover {
        border-radius: 8px;
        background-color: rgba(255, 255, 255, 0.5);
        opacity: 1.0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover,
      #workspaces button.active {
        box-shadow: inherit;
        text-shadow: inherit;
      }

      #workspaces button.empty {
        opacity: 0.5;
      }

      #custom-btc-rate,
      #custom-eth-rate,
      #custom-gala-rate {
      	font-size: 16px;
      	background-position: 3% 50%;
      	background-repeat: no-repeat;
      	background-size: 8%;
      }

      /* Уменьщаем значек для ETH */
      #custom-eth-rate {
      	background-position: 5% 50%;
      	background-size: 6%;
      }

      #custom-btc-rate {
      	color: @white;
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo.svg');
      }

      #custom-eth-rate {
      	color: @white;
      	background-image: url('${config.xdg.configHome}/waybar/icons/eth-rate/eth-logo.svg');
      }

      #custom-gala-rate {
      	color: @white;
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo.svg');
      }

      #custom-btc-rate.rate-up {
      	color: @green;
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo-green.svg');
      }

      #custom-btc-rate.rate-down {
      	color: @red;
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo-red.svg');
      }

      #custom-eth-rate.rate-up {
      	color: @green;
      	background-image: url('${config.xdg.configHome}/waybar/icons/eth-rate/eth-logo-green.svg');
      }

      #custom-eth-rate.rate-down {
      	color: @red;
      	background-image: url('${config.xdg.configHome}/waybar/icons/eth-rate/eth-logo-red.svg');
      }

      #custom-gala-rate.rate-up {
      	color: @green;
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo-green.svg');
      }

      #custom-gala-rate.rate-down {
      	color: @red;
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo-red.svg');
      }

      #custom-weather {
        margin-left: 10px;
      }

      #clock {
      	font-weight: bold;
      }

      #taskbar {
        padding-left: 5px;
        padding-right: 5px;
      }

      #taskbar button {
        padding: 0px 5px;
        margin: 0px 3px;
        border-radius: 6px;
        transition: background-color 0.3s ease;
      }

      #taskbar button.active,
      #taskbar button:hover {
        background-color: rgba(0, 0, 0, 0.3);
      }

      #idle_inhibitor {
        padding-right: 18px;
      }

      #network {
      	margin-right: 10px;
      }

      #bluetooth {
      	margin-right: 5px;
      }

      #pulseaudio {
      	margin-right: 5px;
      }

      #battery {
      	font-weight: bold;
      	color: @green;
      }

      #network.wifi,
      #bluetooth.connected,
      #battery.charging,
      #battery.plugged {
      	color: @blue;
      }

      #temperature.critical,
      #cpu.critical,
      #memory.critical,
      #disk.critical,
      #network.disconnected,
      #bluetooth.off,
      #pulseaudio.muted {
      	color: @red;
      }

      #temperature.warning,
      #cpu.warning,
      #memory.warning,
      #disk.warning,
      #battery.warning:not(.charging) {
      	color: @yellow;
      }

      #battery.critical:not(.charging) {
      	color: @red;
      	animation-name: blink;
      	animation-duration: 0.5s;
      	animation-timing-function: steps(12);
      	animation-iteration-count: infinite;
      	animation-direction: alternate;
      }

      @keyframes blink {
      	to {
      		color: @black;
      	}
      }
    '';
  };

  xdg.configFile = {
    "waybar/icons/btc-rate/btc-logo.svg".source = ./icons/btc-rate/btc-logo.svg;
    "waybar/icons/btc-rate/btc-logo-green.svg".source = ./icons/btc-rate/btc-logo-green.svg;
    "waybar/icons/btc-rate/btc-logo-red.svg".source = ./icons/btc-rate/btc-logo-red.svg;
    "waybar/icons/eth-rate/eth-logo.svg".source = ./icons/eth-rate/eth-logo.svg;
    "waybar/icons/eth-rate/eth-logo-green.svg".source = ./icons/eth-rate/eth-logo-green.svg;
    "waybar/icons/eth-rate/eth-logo-red.svg".source = ./icons/eth-rate/eth-logo-red.svg;
    "waybar/icons/gala-rate/gala-logo.svg".source = ./icons/gala-rate/gala-logo.svg;
    "waybar/icons/gala-rate/gala-logo-green.svg".source = ./icons/gala-rate/gala-logo-green.svg;
    "waybar/icons/gala-rate/gala-logo-red.svg".source = ./icons/gala-rate/gala-logo-red.svg;

    "waybar/scripts/crypto-rates.sh" = {
      source = ./scripts/crypto-rates.sh;
      executable = true;
    };

    "waybar/scripts/weather.sh" = {
      source = ./scripts/weather.sh;
      executable = true;
    };
  };
}
