{ user, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${user.flake}/home-manager/wallpapers/landscape_monicore_instagram.jpg";
      picture-uri-dark = "file://${user.flake}/home-manager/wallpapers/landscape_monicore_instagram.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };
  };
}