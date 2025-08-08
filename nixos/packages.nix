{
  inputs,
  pkgs,
  system,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      home-manager
      curl
      wget
      git
      gzip
      p7zip
      zip
      unzip
      unrar
      inputs.alejandra.defaultPackage.${system}
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
