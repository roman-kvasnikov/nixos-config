{pkgs, ...}: {
  boot = {
    loader = {
      # systemd-boot is the default loader for NixOS
      systemd-boot = {
        enable = true;
        configurationLimit = 20; # 20 boot entries
      };

      # grub is the default loader for NixOS
      # grub = {
      #   enable = true;
      #   efiSupport = true;
      #   device = "nodev";
      #   useOSProber = true;
      # };

      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = {
      # Оптимизация виртуальной памяти для desktop
      "vm.swappiness" = 10;                    # Меньше swap для SSD
      "vm.vfs_cache_pressure" = 50;            # Лучший кеш файловой системы
      "vm.dirty_ratio" = 15;                   # Оптимизация записи
      "vm.dirty_background_ratio" = 5;         # Фоновая запись

      # Сетевые оптимизации
      "net.core.default_qdisc" = "cake";       # Современный QoS
      "net.ipv4.tcp_congestion_control" = "bbr"; # Лучший TCP
      "net.ipv4.tcp_fastopen" = 3;             # Быстрый TCP

      # Безопасность
      "kernel.unprivileged_userns_clone" = 1;  # Для современных приложений
      "kernel.sysrq" = 1;                      # SysRq для debug

      # Производительность
      "kernel.sched_autogroup_enabled" = 1;    # Автогруппировка процессов
    };

    kernelPackages = pkgs.linuxPackages_zen;

    # Современные параметры загрузки
    kernelParams = [
      "quiet"                    # Чистый boot
      "splash"                   # Красивый splash screen
      "mitigations=auto"         # Современные mitigation
      "nowatchdog"              # Отключить watchdog для production
      "modprobe.blacklist=iTCO_wdt" # Отключить Intel watchdog
    ];

    # Поддержка современных файловых систем
    supportedFilesystems = [
      "btrfs"
      "ext4" 
      "xfs"
      "ntfs"
      "exfat"
    ];

    # Оптимизация tmpfs для сборок
    tmp = {
      useTmpfs = true; # Быстрое tmp в RAM
      tmpfsSize = "8G"; # 8GB для временных файлов сборки
    };
  };
}
