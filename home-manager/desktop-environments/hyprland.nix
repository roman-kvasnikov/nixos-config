{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  # =============================================================================
  # HYPRLAND DESKTOP ENVIRONMENT - HOME MANAGER
  # =============================================================================

  # =============================================================================
  # HYPRLAND КОНФИГУРАЦИЯ
  # =============================================================================

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Мониторы
      monitor = [
        ",preferred,auto,1"
      ];

      # Автозапуск приложений
      exec-once = [
        "waybar"
        "mako"
        "swww-daemon"
      ];

      # Клавиатурные сокращения
      bind = [
        # Основные приложения
        "SUPER, Q, exec, kitty"
        "SUPER, E, exec, thunar"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, brave"

        # Управление окнами
        "SUPER, C, killactive,"
        "SUPER, M, exit,"
        "SUPER, V, togglefloating,"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"
        "SUPER, F, fullscreen,"

        # Перемещение между окнами
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        # Рабочие пространства
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # Перенос окон на рабочие пространства
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Мультимедиа
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Скриншоты
        ", Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        "SUPER, Print, exec, grim ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"

        # Блокировка экрана
        "SUPER, L, exec, hyprlock"
      ];

      # Мышь бинды
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # Настройки окон
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Декорации
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Анимации
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Жесты
      gestures = {
        workspace_swipe = true;
      };
    };
  };

  # =============================================================================
  # WAYBAR КОНФИГУРАЦИЯ
  # =============================================================================

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

  # =============================================================================
  # MAKO УВЕДОМЛЕНИЯ
  # =============================================================================

  services.mako.settings = {
    enable = true;
    backgroundColor = "#1e1e2e";
    borderColor = "#89b4fa";
    borderRadius = 8;
    borderSize = 2;
    textColor = "#cdd6f4";
    font = "Ubuntu Nerd Font 11";
    width = 350;
    height = 120;
    defaultTimeout = 8000;
    maxIconSize = 48;
    iconPath = "/run/current-system/sw/share/icons/hicolor";
  };

  # =============================================================================
  # WOFI LAUNCHER
  # =============================================================================

  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 600;
      height = 400;
      location = "center";
      columns = 2;
      orientation = "vertical";
      halign = "fill";
      line_wrap = "off";
      dynamic_lines = false;
      allow_markup = true;
      allow_images = true;
      image_size = 32;
      exec_search = false;
      hide_search = false;
      parse_search = false;
      insensitive = true;
      hide_scroll = false;
      no_actions = true;
      sort_order = "default";
      gtk_dark = true;
      filter_rate = 100;
      key_expand = "Tab";
      key_exit = "Escape";
    };

    style = ''
      window {
        margin: 0px;
        border: 1px solid #3b4252;
        background-color: #2e3440;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #eceff4;
        background-color: #3b4252;
        border-radius: 5px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: #2e3440;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #eceff4;
      }

      #entry {
        margin: 2px;
        border: none;
        border-radius: 5px;
      }

      #entry:selected {
        background-color: #4c566a;
      }
    '';
  };

  # =============================================================================
  # SWAYLOCK ЭКРАН БЛОКИРОВКИ
  # =============================================================================

  programs.swaylock = {
    enable = true;
    settings = {
      color = "2e3440";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "3b4252";
      show-failed-attempts = true;
    };
  };

  # =============================================================================
  # HYPRLAND PACKAGES
  # =============================================================================

  home.packages = with pkgs; [
    # Hyprland утилиты
    hyprpaper # Обои
    hypridle # Управление простоем
    hyprlock # Блокировка экрана
    hyprpicker # Цветовая пипетка

    # Wayland утилиты
    wl-clipboard # Буфер обмена
    wf-recorder # Запись экрана
    grim # Скриншоты
    slurp # Выбор области
    swappy # Редактор скриншотов

    # Файловый менеджер
    nautilus

    # Системные утилиты
    brightnessctl # Яркость
    pamixer # Громкость
    playerctl # Медиа управление
  ];

  # =============================================================================
  # XDG НАСТРОЙКИ ДЛЯ HYPRLAND
  # =============================================================================

  xdg = {
    enable = true;

    mimeApps = {
      enable = true;

      defaultApplications = {
        # Веб-браузер
        "text/html" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];

        # Файловый менеджер
        "inode/directory" = ["thunar.desktop"];

        # Терминал
        "application/x-terminal-emulator" = ["kitty.desktop"];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # =============================================================================
  # ENVIRONMENT VARIABLES ДЛЯ HYPRLAND
  # =============================================================================

  home.sessionVariables = {
    # Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";

    # QT
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # NVIDIA (если нужно)
    # WLR_NO_HARDWARE_CURSORS = "1";
    # LIBVA_DRIVER_NAME = "nvidia";
  };

  # =============================================================================
  # СОЗДАНИЕ ДИРЕКТОРИЙ
  # =============================================================================

  home.file."Pictures/Screenshots/.keep".text = "";

  # =============================================================================
  # HYPRPAPER WALLPAPERS
  # =============================================================================

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = ["${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png"];
      wallpaper = [",${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png"];
    };
  };

  # =============================================================================
  # HYPRIDLE & HYPRLOCK
  # =============================================================================

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

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
          path = "${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };
}
