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
        ];

        modules-center = [
          "custom/weather"
          "clock"
        ];

        modules-right = [
          "custom/crypto-rates"
          "hyprland/language"
          "group/hardware"
          "battery"
        ];

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

        "custom/weather" = {
          format = "{}";
          interval = 3600;
          exec = "curl 'wttr.in/?format=%c+%t&lang=en'";
          tooltip = false;
        };

        clock = {
          format = "{:%a %b %d %H:%M}";
          interval = 1;
          on-click-right = "gnome-calendar";
          tooltip = false;
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

        "group/hardware" = {
          orientation = "horizontal";
          modules = ["network" "bluetooth"];
        };

        network = {
          format-wifi = "{icon}";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format-disconnected = "󰤭";
          format-disabled = "󰤭";
          tooltip = false;
          on-click = "kitty -e nmtui-connect";
          on-click-right = "nm-connection-editor";
        };

        bluetooth = {
          format-connected = "󰂯";
          format-on = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          tooltip = false;
          on-click-right = "blueman-manager";
        };

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

        "hyprland/language" = {
          format = "{}";
          format-en = "en";
          format-ru = "ru";
        };

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
      };
    };

    style = lib.mkForce ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;

        font-family: "Fira Code Nerd Font";
        font-size: 18px;
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      window#waybar {
        background-color: #1e1e2e;
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
          border-bottom: 2px solid #cdd6f4;
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

      #crypto-rates * {
          font-size: 1rem;
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

      #network {
        margin-right: 10px;
      }

      #hardware, #language {
        margin-right: 15px;
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
