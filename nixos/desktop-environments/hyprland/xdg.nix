{pkgs, ...}: {
  xdg.portal = {
    enable = true;

    wlr.enable = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];

    configPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal
    ];
  };
}
