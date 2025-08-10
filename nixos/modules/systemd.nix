{pkgs, ...}: {
  systemd = {
    services = {
      # Быстрый запуск NetworkManager
      NetworkManager-wait-online.enable = false;

      # Оптимизация загрузки
      systemd-networkd-wait-online.enable = false;

      nix-gc.serviceConfig = {
        IOSchedulingClass = 3; # Idle priority для GC
        Nice = 15; # Низкий приоритет
      };
    };

    # Оптимизация пользовательских сервисов
    user = {
      # Увеличить лимиты для пользователя
      extraConfig = ''
        DefaultLimitNOFILE=65536
        DefaultLimitSTACK=8388608
      '';

      services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}
