{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
  ];

  xdg.desktopEntries.btop = {
    name = "Btop++";
    comment = "Resource monitor";
    exec = "kitty -e btop";
    icon = "btop";
    categories = ["System" "Monitor"];
  };
}
