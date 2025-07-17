{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    brave
    code-cursor
    obsidian
    telegram-desktop
    kitty
    warp-terminal
    font-awesome

    # CLI utils
    bc
    bottom
    cliphist
    fastfetch
    wl-clipboard
  ];
}
