{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    brave
    code-cursor
    evince
    gimp inkscape pinta
    kitty
    obsidian
    keepassxc
    telegram-desktop
    vlc
    warp-terminal

    # CLI utils
    bc
    bottom
    calc
    cliphist
    fastfetch
    wl-clipboard
  ];
}
