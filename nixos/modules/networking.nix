{
  hostname,
  pkgs,
  ...
}: {
  networking = {
    hostName = hostname;

    networkmanager = {
      enable = true;

      wifi.powersave = false; # Отключить powersave для Wi-Fi
      ethernet.macAddress = "preserve"; # Сохранить MAC адрес
      dns = "systemd-resolved"; # Современный DNS resolver

      plugins = with pkgs; [
        networkmanager-l2tp
      ];
    };

    # Современный firewall
    firewall = {
      enable = true;

      allowPing = true;
      logReversePathDrops = true;

      # Разрешить локальные сервисы для разработки
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };
}
