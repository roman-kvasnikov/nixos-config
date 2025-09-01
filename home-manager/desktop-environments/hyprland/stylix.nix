{pkgs, ...}: {
  stylix = {
    targets = {
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
      mako.enable = true;
      hyprlock.enable = true;
    };

    cursor = {
      name = "DMZ-Black";
      size = 24;
      package = pkgs.vanilla-dmz;
    };

    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}
