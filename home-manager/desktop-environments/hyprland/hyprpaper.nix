{inputs, ...}: {
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      preload = ["${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png"];
      wallpaper = [",${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png"];
    };
  };
}
