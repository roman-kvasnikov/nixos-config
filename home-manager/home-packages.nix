{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    brave
    code-cursor
    evince
    exodus electrum
    gimp inkscape pinta
    keepassxc
    kitty
    libreoffice-still
    obsidian
    postman
    tableplus
    telegram-desktop
    whatsapp-for-mac
    vlc
    warp-terminal

    # CLI utils
    bc
    bottom
    calc
    cliphist
    fastfetch
    ranger
    wl-clipboard
  ];
}
