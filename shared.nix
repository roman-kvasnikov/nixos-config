{
  user = {
    name = "romank";
  };

  hosts = let
    hostList = [
      {
        hostname = "huawei";
        desktop = "hyprland";
      }
      {
        hostname = "nixos";
        desktop = "hyprland";
      }
      {
        hostname = "nixos-vm";
        desktop = "gnome";
      }
    ];

    hostDefaults = {
      system = "x86_64-linux";
      version = "25.11";
    };
  in
    map (host: hostDefaults // host) hostList;
}
