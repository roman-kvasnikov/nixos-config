{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      home-manager

      # CLI utils
      bc calc
      btop htop
      curl wget
      gzip p7zip zip unzip unrar
      tree

      # Gnome
      gnome-tweaks
      gnome-extension-manager

      # Gnome extensions
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