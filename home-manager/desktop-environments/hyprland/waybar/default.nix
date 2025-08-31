{
  config,
  lib,
  ...
}: {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        reload_style_on_change = true;
        layer = "top";
        position = "top";
        spacing = 0;
        height = 30;

        modules-left = [
          "hyprland/workspaces"
          "group/crypto-rates"
        ];

        modules-center = [
          "custom/weather"
          "clock"
        ];

        modules-right = [
          "hyprland/language"
          "group/hardware"
          "battery"
        ];

        # =================================================================
        # WORKSPACES
        # =================================================================

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            active = "󱓻";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
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
          format = "    {}{icon}";
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
          format = "    {}{icon}";
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

        # =================================================================
        # WEATHER AND CLOCK
        # =================================================================

        "custom/weather" = {
          format = "{}";
          interval = 3600;
          exec = "curl 'https://wttr.in/Saint-Petersburg?format=%c+%t&lang=en'";
          tooltip = false;
        };

        clock = {
          format = "{:%a %b %d %H:%M}";
          interval = 1;
          on-click = "gnome-calendar";
          tooltip = false;
        };

        # =================================================================
        # HARDWARE GROUP
        # =================================================================

        "group/hardware" = {
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
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          on-click = "kitty -e nmtui-connect";
          on-click-right = "kitty -e nmtui";
        };

        bluetooth = {
          format-connected = "󰂯";
          format-on = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          tooltip = true;
          tooltip-format = "Devices connected: {num_connections}";
          on-click-right = "blueberry";
        };

        "pulseaudio" = {
          format = "{icon} ";
          format-muted = " ";
          format-bluetooth = "{icon} 󰂯 ";
          format-bluetooth-muted = " 󰂯 ";
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
          format = "{icon} ";
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
        # LANGUAGE
        # =================================================================

        "hyprland/language" = {
          format-en = "🇺🇸 en";
          format-ru = "🇷🇺 ru";
          min-length = 4;
          tooltip = false;
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
          format-full = "󰁹 {capacity}%";
          format-charging = " {capacity}%";
          format-icons = ["" "" "" "" ""];
          tooltip = false;
        };
      };
    };

    style = ''
      @define-color black #000000;
      @define-color white #c7c7c7;
      @define-color green #33cc00;
      @define-color yellow #ffff66;
      @define-color red #ff3300;
      @define-color blue #103cfe;

      * {
      	border: none;
      	border-radius: 0;
      	min-height: 0;

      	font-family: 'Fira Code Nerd Font';
      	font-size: 18px;
      	color: @white;
      }

      .modules-left {
      	margin-left: 8px;
      }

      .modules-right {
      	margin-right: 8px;
      }

      window#waybar {
      	background-color: @black;
      	opacity: 0.8;
      }

      #workspaces button {
      	all: initial;
      	padding: 0 6px;
      	margin: 0 4px;
      	min-width: 15px;
      }

      #workspaces button.empty {
      	opacity: 0.5;
      }

      #workspaces button.active {
      	border-bottom: 2px solid @white;
      }

      #workspaces button:hover {
      	font-weight: bold;
      }

      #custom-weather {
      	margin-right: 10px;
      }

      #clock {
      	font-weight: bold;
      }

      #crypto-rates {
      	margin-left: 10px;
      }

      #crypto-rates * {
      	background-position: 8% 46%;
      	background-repeat: no-repeat;
      	background-size: 8%;
      }

      #custom-btc-rate {
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo.svg');
      }

      #custom-gala-rate {
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo.svg');
      }

      #custom-btc-rate.rate-up {
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo-green.svg');
      }

      #custom-btc-rate.rate-down {
      	background-image: url('${config.xdg.configHome}/waybar/icons/btc-rate/btc-logo-red.svg');
      }

      #custom-gala-rate.rate-up {
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo-green.svg');
      }

      #custom-gala-rate.rate-down {
      	background-image: url('${config.xdg.configHome}/waybar/icons/gala-rate/gala-logo-red.svg');
      }

      #crypto-rates *.rate-up {
      	color: @green;
      }

      #crypto-rates *.rate-down {
      	color: @red;
      }

      #crypto-rates *.rate-same {
      	color: @white;
      }

      #network.disconnected,
      #bluetooth.off {
      	color: @red;
      }

      #language {
      	margin-right: 20px;
      }

      #hardware {
      	margin-right: 10px;
      }

      #network {
      	margin-right: 10px;
      }

      #bluetooth {
      	font-weight: bold;
      	margin-right: 5px;
      }

      #pulseaudio {
      	margin-right: 1px;
      }

      #battery {
        font-weight: bold;
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
      	color: @red;
      	animation-name: blink;
      	animation-duration: 0.5s;
      	animation-timing-function: steps(12);
      	animation-iteration-count: infinite;
      	animation-direction: alternate;
      }
    '';
  };

  home.file = {
    ".config/waybar/icons/btc-rate/btc-logo.svg".source = ./icons/btc-rate/btc-logo.svg;
    ".config/waybar/icons/btc-rate/btc-logo-green.svg".source = ./icons/btc-rate/btc-logo-green.svg;
    ".config/waybar/icons/btc-rate/btc-logo-red.svg".source = ./icons/btc-rate/btc-logo-red.svg;
    ".config/waybar/icons/gala-rate/gala-logo.svg".source = ./icons/gala-rate/gala-logo.svg;
    ".config/waybar/icons/gala-rate/gala-logo-green.svg".source = ./icons/gala-rate/gala-logo-green.svg;
    ".config/waybar/icons/gala-rate/gala-logo-red.svg".source = ./icons/gala-rate/gala-logo-red.svg;

    ".config/waybar/scripts/crypto-rates.sh".source = ./scripts/crypto-rates.sh;
    ".config/waybar/scripts/weather.sh".source = ./scripts/weather.sh;
  };
}
