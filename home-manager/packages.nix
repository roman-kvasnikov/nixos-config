{pkgs, ...}: {
  home.packages = with pkgs; [
    # CLI utilites
    bat
    bc
    calc
    btop
    htop
    claude-code
    cliphist
    wl-clipboard
    eza
    fastfetch
    ffmpeg
    ffmpegthumbnailer
    kitty
    ranger
    silicon
    tree
    xray

    # Desktop apps
    bottom
    evince
    #exodus
    electrum
    filezilla
    gimp
    inkscape
    pinta
    krita
    hiddify-app
    keepassxc
    libreoffice-still
    obsidian
    postman
    #tableplus
    telegram-desktop
    vlc
    warp-terminal

    # Gnome Applications
    gnome-tweaks
    gnome-extension-manager

    # Gnome Extensions
    gnomeExtensions.bitcoin-markets
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-history
    gnomeExtensions.dash-to-dock
    gnomeExtensions.desktop-cube
    gnomeExtensions.just-perfection
    gnomeExtensions.search-light
  ];
}
