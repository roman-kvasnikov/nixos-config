{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      home-manager

      btop htop
      curl wget
      git
      gzip p7zip zip unzip unrar xarchiver

      gnome-tweaks

      # Расширения
      gnomeExtensions.bitcoin-markets
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-history
      gnomeExtensions.dash-to-dock
      gnomeExtensions.desktop-cube
      gnomeExtensions.search-light

      # Fonts
      noto-fonts
      fira-code
      font-awesome
      cascadia-code
      dina-font
      proggyfonts
    ];

    gnome.excludePackages = with pkgs; [
      # Ненужные приложения
      gnome-tour
      gnome-music
      gnome-photos
      gnome-contacts
      gnome-characters
      file-roller
      simple-scan
      seahorse
      epiphany
      geary
      evolution
      totem

      # Игры
      aisleriot
      gnome-chess
      gnome-mahjongg 
      iagno
      tali
      hitori
      atomix

      # Документация
      yelp
      gnome-user-docs
    ];
  };
}