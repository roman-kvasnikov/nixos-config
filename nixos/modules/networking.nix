{
  hostname,
  pkgs,
  ...
}: {
  networking = {
    hostName = hostname;

    hosts = {
      "192.168.1.1" = ["local.keenetic"];
      "192.168.1.10" = ["local.nas"];
      "192.168.1.20" = ["local.izolda-rally"];
    };

    networkmanager = {
      enable = true;

      wifi.powersave = false; # Отключить powersave для Wi-Fi
      ethernet.macAddress = "preserve"; # Сохранить MAC адрес
      dns = "systemd-resolved"; # Современный DNS resolver
    };

    firewall = {
      enable = true;

      allowPing = true;
      logReversePathDrops = true;
    };
  };
}
