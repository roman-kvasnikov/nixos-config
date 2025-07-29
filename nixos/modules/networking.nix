{
  hostname,
  pkgs,
  ...
}: {
  networking = {
    hostName = hostname;

    networkmanager = {
      enable = true;

      plugins = with pkgs; [
        networkmanager-l2tp
      ];
    };

    #wireless.enable = true;
  };
}
