{
  config,
  lib,
  pkgs,
  ...
}: let
  buildinMon = "eDP-1,3120x2080@90.00, auto, 1.6"; # Встроенный монитор ноутбука
  externalMon = "DP-3, 2560x1440@165.00, auto, 1"; # Внешний монитор
  fallbackMon = ",preferred,auto,1"; # Fallback правило для любых других мониторов

  # Скрипт для переключения дисплеев
  displaySwitcherScript =
    pkgs.writeShellScriptBin "hyprland-display-switcher"
    ''
      #!/usr/bin/env bash

      sleep 2

      # Функция для подсчета подключенных мониторов
      count_monitors() {
          ${pkgs.hyprland}/bin/hyprctl monitors | grep -c '^Monitor'
      }

      # Функция для извлечения имени монитора
      monitor_name() {
          local config_string="$1"
          echo "$config_string" | cut -d',' -f1
      }

      # Функция для отключения встроенного монитора
      disable_builtin() {
          echo "Disabling built-in monitor"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$(monitor_name "${buildinMon}"),disable"
      }

      # Функция для включения встроенного монитора
      enable_builtin() {
          echo "Enabling built-in monitor"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "${buildinMon}"
      }

      # Основная логика
      monitor_count=$(count_monitors)
      echo "Current monitor count: $monitor_count"

      if [ "$monitor_count" -gt 1 ]; then
          # Если подключен внешний монитор, отключаем встроенный
          disable_builtin
      else
          # Если только встроенный монитор, включаем его
          enable_builtin
      fi
    '';
in {
  # Пакеты
  home.packages = [displaySwitcherScript];

  # Настройка Hyprland
  wayland.windowManager.hyprland.settings = {
    # Автозапуск скрипта при старте Hyprland
    exec-once = [
      "${displaySwitcherScript}/bin/hyprland-display-switcher"
    ];

    # Настройки мониторов
    monitor = [
      # Основной внешний монитор
      "${externalMon}"
      # Встроенный монитор ноутбука
      "${buildinMon}"
      # Fallback правило для любых других мониторов
      "${fallbackMon}"
    ];
  };

  # Systemd пользовательский сервис
  systemd.user.services.hyprland-display-switcher = {
    Unit = {
      Description = "Hyprland Display Switcher";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${displaySwitcherScript}/bin/hyprland-display-switcher";
      Environment = [
        "HYPRLAND_INSTANCE_SIGNATURE=%i"
      ];
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Дополнительный скрипт для ручного переключения
  xdg.configFile."hypr/scripts/toggle-display.sh" = {
    text = ''
      #!/usr/bin/env bash

      monitor_name() {
          local config_string="$1"
          echo "$config_string" | cut -d',' -f1
      }

      # Проверяем статус встроенного монитора
      builtin_status=$(${pkgs.hyprland}/bin/hyprctl monitors | grep "$(monitor_name "${buildinMon}")" | wc -l)

      if [ "$builtin_status" -eq 0 ]; then
          echo "Enabling built-in monitor"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "${buildinMon}"
      else
          echo "Disabling built-in monitor"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$(monitor_name "${buildinMon}"),disable"
      fi
    '';
    executable = true;
  };

  # Добавляем горячие клавиши для ручного переключения
  # wayland.windowManager.hyprland.settings.bind = [
  #   # Super + P для ручного переключения дисплеев
  #   "SUPER, P, exec, ~/.config/hypr/scripts/toggle-display.sh"
  #   # Super + Shift + P для запуска автоматического переключателя
  #   "SUPER_SHIFT, P, exec, ${displaySwitcherScript}/bin/hyprland-display-switcher"
  # ];
}
