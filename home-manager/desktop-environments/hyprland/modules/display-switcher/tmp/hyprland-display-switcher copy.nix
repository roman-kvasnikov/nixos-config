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
          echo "$1" | cut -d',' -f1
      }

      # Основная логика
      monitor_count=$(count_monitors)
      echo "Current monitor count: $monitor_count"

      if [ "$monitor_count" -gt 1 ]; then
          # Если подключен внешний монитор, отключаем встроенный
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$(monitor_name "${buildinMon}"),disable"
      else
          # Если только встроенный монитор, включаем его
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "${buildinMon}"
      fi
    '';
in {
  # Пакеты
  home.packages = [displaySwitcherScript];

  # Systemd пользовательский сервис
  systemd.user.services.hyprland-display-switcher = {
    Unit = {
      Description = "Hyprland Display Switcher";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
      Requires = ["hyprland-session.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${displaySwitcherScript}/bin/hyprland-display-switcher";
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

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

  # Дополнительный скрипт для ручного переключения
  xdg.configFile."hypr/scripts/toggle-builtin-monitor.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Функция для извлечения имени монитора
      monitor_name() {
          echo "$1" | cut -d',' -f1
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
}
