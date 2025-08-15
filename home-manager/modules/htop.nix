{pkgs, ...}: {
  home.packages = with pkgs; [
    htop
  ];

  xdg.desktopEntries.htop = {
    name = "Htop";
    comment = "Interactive process viewer";
    exec = "kitty -e htop";
    icon = "utilities-system-monitor";
    categories = ["System" "Monitor"];
  };
}
