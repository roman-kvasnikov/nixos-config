# Управление батареей ноутбука в NixOS
{pkgs, lib, config, ...}: {

  # === THINKPAD BATTERY MANAGEMENT ===
  
  # Для ThinkPad - встроенная поддержка
  services.tlp = {
    enable = true;
    settings = {
      # Ограничения зарядки батареи (рекомендуется 20-80% для долговечности)
      START_CHARGE_THRESH_BAT0 = 20;  # Начинать зарядку при 20%
      STOP_CHARGE_THRESH_BAT0 = 80;   # Останавливать зарядку при 80%
      START_CHARGE_THRESH_BAT1 = 20;  # Для второй батареи (если есть)
      STOP_CHARGE_THRESH_BAT1 = 80;
      
      # Энергосберегающие настройки
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Оптимизация для SSD
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";
      
      # Wi-Fi энергосбережение
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # USB автоотключение
      USB_AUTOSUSPEND = 1;
      
      # Настройки дисплея
      INTEL_GPU_MIN_FREQ_ON_AC = 100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;
      INTEL_GPU_MAX_FREQ_ON_AC = 1200;  
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
    };
  };

  # === АЛЬТЕРНАТИВНЫЕ МЕТОДЫ ДЛЯ ДРУГИХ БРЕНДОВ ===
  
  # Для ASUS ноутбуков с ASUS WMI
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # asus-wmi-sensors  # Если нужно
  ];
  
  # Универсальный метод через udev правила и sysfs
  services.udev.extraRules = ''
    # ThinkPad charge thresholds (автоматически через tlp)
    # ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT*/charge_control_end_threshold'"
    
    # ASUS charge control (раскомментировать для ASUS)
    # ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT*/charge_control_end_threshold'"
    
    # Dell charge control (раскомментировать для Dell)  
    # ACTION=="add", SUBSYSTEM=="platform", KERNEL=="dell-laptop", RUN+="${pkgs.bash}/bin/bash -c 'echo 1 > /sys/class/power_supply/BAT*/charge_control_start_threshold && echo 80 > /sys/class/power_supply/BAT*/charge_control_end_threshold'"
    
    # HP charge control (раскомментировать для HP)
    # ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", TEST=="/sys/class/power_supply/BAT*/charge_control_end_threshold", RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT*/charge_control_end_threshold'"
    
    # Lenovo (не ThinkPad) charge control
    # ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", TEST=="/sys/class/power_supply/BAT*/charge_control_end_threshold", RUN+="${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT*/charge_control_end_threshold'"
  '';

  # === ДОПОЛНИТЕЛЬНЫЕ УТИЛИТЫ ===
  
  environment.systemPackages = with pkgs; [
    # Мониторинг батареи
    acpi              # Информация о батарее
    powertop          # Анализ энергопотребления  
    
    # Утилиты для батареи
    tlp               # TLP утилиты
    # tpacpi-bat       # Для старых ThinkPad
    
    # Мониторинг температуры
    lm_sensors        # Датчики температуры
    psensor           # GUI для мониторинга
  ];

  # === SYSTEMD СЕРВИСЫ ДЛЯ ПРОДВИНУТОГО УПРАВЛЕНИЯ ===
  
  # Кастомный сервис для установки порогов батареи при загрузке
  systemd.services.battery-charge-threshold = {
    description = "Set battery charge thresholds";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeScript "set-battery-threshold" ''
        #!${pkgs.bash}/bin/bash
        
        # Автоопределение производителя
        VENDOR=$(${pkgs.dmidecode}/bin/dmidecode -s system-manufacturer 2>/dev/null | tr '[:upper:]' '[:lower:]')
        
        # Функция для установки порогов
        set_threshold() {
            local bat_path="$1"
            local start_thresh="$2" 
            local end_thresh="$3"
            
            if [ -w "$bat_path/charge_control_start_threshold" ]; then
                echo "$start_thresh" > "$bat_path/charge_control_start_threshold" 2>/dev/null || true
                echo "Set start threshold to $start_thresh for $bat_path"
            fi
            
            if [ -w "$bat_path/charge_control_end_threshold" ]; then
                echo "$end_thresh" > "$bat_path/charge_control_end_threshold" 2>/dev/null || true
                echo "Set end threshold to $end_thresh for $bat_path"
            fi
        }
        
        # Установить пороги для всех найденных батарей
        for bat in /sys/class/power_supply/BAT*; do
            if [ -d "$bat" ]; then
                echo "Found battery: $bat"
                set_threshold "$bat" 20 80
            fi
        done
        
        # Специфичные настройки по производителям
        case "$VENDOR" in
            *thinkpad*|*lenovo*)
                echo "Detected ThinkPad/Lenovo - TLP should handle this"
                ;;
            *asus*)
                echo "Detected ASUS laptop"
                # Дополнительные настройки для ASUS если нужно
                ;;
            *dell*)
                echo "Detected Dell laptop" 
                # Дополнительные настройки для Dell если нужно
                ;;
            *hp*|*hewlett*)
                echo "Detected HP laptop"
                # Дополнительные настройки для HP если нужно
                ;;
            *)
                echo "Unknown vendor: $VENDOR - using generic approach"
                ;;
        esac
        
        echo "Battery threshold setup completed"
      '';
    };
  };

  # === GNOME POWER MANAGEMENT ИНТЕГРАЦИЯ ===
  
  # Настройки энергосбережения для GNOME
  services.upower = {
    enable = true;
    percentageLow = 20;      # Низкий заряд при 20%
    percentageCritical = 10; # Критический заряд при 10%
    percentageAction = 5;    # Действие при 5%
    criticalPowerAction = "PowerOff"; # Выключение при критическом заряде
  };

  # === ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ЯДРА ===
  
  # Модули ядра для управления батареей
  boot.kernelModules = [
    # "thinkpad_acpi"    # Для ThinkPad (автоматически загружается)
    # "asus_wmi"         # Для ASUS
    # "dell_laptop"      # Для Dell
    # "hp_wmi"           # Для HP
  ];
  
  # Параметры ядра для энергосбережения
  boot.kernelParams = [
    # "acpi_backlight=vendor"    # Если проблемы с подсветкой
  ];

  # === ПОЛЬЗОВАТЕЛЬСКИЕ КОМАНДЫ ===
  
  # Создать алиасы для проверки состояния батареи
  environment.shellAliases = {
    battery-status = "acpi -b";
    battery-info = "upower -i \$(upower -e | grep 'BAT')";
    battery-thresholds = "cat /sys/class/power_supply/BAT*/charge_control_*_threshold 2>/dev/null || echo 'Thresholds not available'";
    powertop-report = "sudo powertop --html=powertop-report.html";
  };
}