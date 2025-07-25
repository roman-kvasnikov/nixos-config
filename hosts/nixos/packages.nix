{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      home-manager

      # CLI utils
      bat
      bc calc
      btop htop
      eza
      curl wget
      git
      cliphist wl-clipboard
      fastfetch
      gzip p7zip zip unzip unrar
      kitty
      ranger
      tree

      # Applications
      bottom

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
    ];

    gnome.excludePackages = with pkgs; [
      # Applications
      gnome-tour
      gnome-music
      gnome-photos
      gnome-contacts
      gnome-characters
      gnome-terminal
      file-roller
      simple-scan
      seahorse
      epiphany
      geary
      evolution
      totem

      # Games
      aisleriot
      gnome-chess
      gnome-mahjongg 
      iagno
      tali
      hitori
      atomix

      # Documentation
      yelp
      gnome-user-docs
    ];
  };
}