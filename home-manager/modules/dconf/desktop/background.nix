{ user, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${user.dirs.nixos-config}/home-manager/wallpapers/landscape_monicore_instagram.jpg";
      picture-uri-dark = "file://${user.dirs.nixos-config}/home-manager/wallpapers/landscape_monicore_instagram.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };
  };
}