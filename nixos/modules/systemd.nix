{pkgs, ...}: {
  systemd = {
    services = {
      NetworkManager-wait-online.enable = true;

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
    };
  };
}
