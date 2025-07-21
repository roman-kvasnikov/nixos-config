{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    brave
    evince
    #exodus
    electrum
    filezilla
    gimp inkscape pinta
    hiddify-app
    keepassxc
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
