{pkgs, ...}: {
  imports = [
    ./extensions
    ./weather.nix
    # ./world-clocks.nix
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = with pkgs.gnomeExtensions; [
        "bitcoin-markets@ottoallmendinger.github.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "clipboard-history@alexsaveau.dev"
        "dash-to-dock@micxgx.gmail.com"
        "desktop-cube@schneegans.github.com"
        "just-perfection-desktop@just-perfection"
        "search-light@icedman.github.com"
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
