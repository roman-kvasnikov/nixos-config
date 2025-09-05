{
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
      format = "{icon}";
      format-icons = {
        "default" = "";
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "<span class='keepassxc'> </span>";
        "5" = "";
        "6" = "6";
        "7" = "7";
        "8" = "8";
        "9" = "9";
        "active" = "";
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
    # CRYPTO RATES
    # =================================================================

    "custom/btc-rate" = {
      format = "  {}";
      interval = 300;
      exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c BTC -r 0";
      return-type = "json";
      on-click = "bash ~/.config/waybar/scripts/open-link.sh 'https://www.bybit.com/ru-RU/trade/spot/BTC/USDT'";
      tooltip = false;
    };

    "custom/eth-rate" = {
      format = "  {}";
      interval = 300;
      exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c ETH -r 0";
      return-type = "json";
      on-click = "bash ~/.config/waybar/scripts/open-link.sh 'https://www.bybit.com/ru-RU/trade/spot/ETH/USDT'";
      tooltip = false;
    };

    "custom/gala-rate" = {
      format = "  {}";
      interval = 300;
      exec = "bash ~/.config/waybar/scripts/crypto-rates.sh -c GALA -r 5";
      return-type = "json";
      on-click = "bash ~/.config/waybar/scripts/open-link.sh 'https://www.bybit.com/ru-RU/trade/spot/GALA/USDT'";
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
      on-click = "bash ~/.config/waybar/scripts/open-link.sh 'https://dzen.ru/pogoda/?lat=59.93867493&lon=30.31449318'";
      tooltip = true;
    };

    clock = {
      format = " {:%a %b %d  %H:%M}";
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
      icon-size = 24;
      tooltip-format = "{name}";
      on-click = "activate";
      on-click-middle = "close";
      ignore-list = [
        "wofi"
        "kitty"
        "dev.warp.Warp"
        "org.keepassxc.KeePassXC"
      ];
    };

    "idle_inhibitor" = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
      timeout = 60;
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
      on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard prev";
      on-scroll-up = "hyprctl switchxkblayout at-translated-set-2-keyboard prev";
      on-scroll-down = "hyprctl switchxkblayout at-translated-set-2-keyboard prev";
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
      # format-icons = [
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      #   ""
      # ];
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
}
