{ pkgs, ... }:

{
  imports = [
    ./extensions
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        bitcoin-markets.extensionUuid
        blur-my-shell.extensionUuid
        caffeine.extensionUuid
        clipboard-history.extensionUuid
        dash-to-dock.extensionUuid
        desktop-cube.extensionUuid
        search-light.extensionUuid
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "brave-browser.desktop"
        "hiddify.desktop"
        # "DeepSeek.desktop"
        # "WhatsApp.desktop"
        "org.telegram.desktop.desktop"
        "org.keepassxc.KeePassXC.desktop"
      ];
    };
  };
}