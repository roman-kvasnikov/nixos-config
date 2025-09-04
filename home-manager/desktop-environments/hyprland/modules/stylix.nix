{pkgs, ...}: {
  stylix = {
    targets = {
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
      mako.enable = true;
      hyprlock.enable = true;
    };

    # cursor = {
    #   package = pkgs.vanilla-dmz;
    #   name = "DMZ-Black";
    #   size = 24;
    # };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 22;
    };

    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}
