{inputs, ...}: {
  user = {
    name = "romank";
  };

  hosts = let
    hostList = [
      {
        hostname = "huawei";
        desktop = "hyprland";
        wallpaper = "${inputs.wallpapers}/banff-day.jpg";
      }
      {
        hostname = "nixos";
        desktop = "hyprland";
        wallpaper = "${inputs.wallpapers}/banff-day.jpg";
      }
      {
        hostname = "nixos-vm";
        desktop = "gnome";
        wallpaper = "${inputs.wallpapers}/banff-day.jpg";
      }
    ];

    hostDefaults = {
      system = "x86_64-linux";
      version = "25.11";
    };
  in
    map (host: hostDefaults // host) hostList;
}
