{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
  ];

  xdg.desktopEntries.btop = {
    name = "Btop++";
    comment = "Resource monitor";
    exec = "kitty -e btop";
    icon = "utilities-system-monitor";
    categories = ["System" "Monitor"];
  };
}
