{ pkgs, ... }: {
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
    btop
    curl
    cliphist
    fastfetch
    ffmpeg
    ffmpegthumbnailer
    fzf
    git
    git-graph
    grimblast
    htop
    unzip
    w3m
    wget
    wl-clipboard
    zip

    # Other
    bemoji
    nix-prefetch-scripts
  ];
}
