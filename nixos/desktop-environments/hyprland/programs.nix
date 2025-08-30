{
  programs = {
    hyprland = {
      enable = true;

      portalPackages = with pkgs; [
        xdg-desktop-portal-hyprland
      ];

      withUWSM = false;
      xwayland.enable = true;
    };
  };
}
