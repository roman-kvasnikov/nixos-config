{pkgs, ...}: {
  home.packages = with pkgs; [
    exodus
  ];

  xdg.dataFile."icons/exodus.png".source = ./icon.png;

  xdg.desktopEntries.exodus.icon = "exodus";
}
