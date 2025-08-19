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
    };

    firewall = {
      enable = true;

      allowPing = true;
      logReversePathDrops = true;
    };
  };
}
