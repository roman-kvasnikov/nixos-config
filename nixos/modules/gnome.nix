{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      excludePackages = with pkgs.gnome; [
        # Ненужные приложения
        gnome-tour
        gnome-music
        gnome-photos
        gnome-contacts
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
      packages = with pkgs; [
        gnome.gnome-tweaks

        # Расширения
        gnomeExtensions.bitcoin-markets
        gnomeExtensions.blur-my-shell
        gnomeExtensions.caffeine
        gnomeExtensions.clipboard-history
        gnomeExtensions.dash-to-dock
        gnomeExtensions.desktop-cube
        gnomeExtensions.search-light
      ];
    };
  };

  programs.dconf.enable = true;
}