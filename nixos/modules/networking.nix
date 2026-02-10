{
  hostname,
  pkgs,
  ...
}: {
  networking = {
    hostName = hostname;

    # nameservers = [
    #   "192.168.1.2"
    # ];

    proxy.default = "socks://127.0.0.1:10808";
    proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";

    networkmanager = {
      enable = true;

      wifi.powersave = false; # Отключить powersave для Wi-Fi
      ethernet.macAddress = "preserve"; # Сохранить MAC адрес
      # dns = "none";
    };

    firewall = {
      enable = true;

      allowPing = true;
      logReversePathDrops = true;
    };
  };
}
