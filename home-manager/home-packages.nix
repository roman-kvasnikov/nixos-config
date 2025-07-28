{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI utilites
    bat
    bc calc
    btop htop
    cliphist wl-clipboard
    eza
    fastfetch
    ffmpeg
    ffmpegthumbnailer
    kitty
    ranger
    silicon
    tree

    # Desktop apps
    bottom
    # brave
    evince
    #exodus
    electrum
    filezilla
    gimp inkscape pinta
    hiddify-app
    keepassxc
    libreoffice-still
    # obsidian
    postman
    #tableplus
    telegram-desktop
    #whatsapp-for-mac
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
    gnomeExtensions.search-light

    nixfmt-rfc-style # nixfmt - утилита для форматирования кода NIX в стиле RFC
  ];
}
