{pkgs, ...}: {
  home.packages = with pkgs; [
    bottom
  ];

  xdg.desktopEntries.bottom = {
    name = "Bottom";
    comment = "System monitor";
    exec = "kitty -e btm";
    icon = "utilities-system-monitor";
    categories = ["System" "Monitor"];
  };
}
