{
  hostname,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    ./overlays/networkmanager-l2tp.nix
  ];

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
      allowedUDPPorts = [
        500 # ISAKMP
        4500 # NAT-T
        1701 # L2TP
      ];
    };
  };
}
