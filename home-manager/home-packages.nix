{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # CLI utils
    cliphist wl-clipboard
    ranger

    # Desktop apps
    bottom
    brave
    code-cursor
    evince
    #exodus
    electrum
    filezilla
    gimp inkscape pinta
    hiddify-app
    keepassxc
    kitty
    libreoffice-still
    obsidian
    postman
    #tableplus
    telegram-desktop
    #whatsapp-for-mac
    vlc
    warp-terminal
  ];
}
