{pkgs, ...}: {
  home.packages = with pkgs; [
    gnome-calculator # Calculator
    gnome-calendar # Calendar
    nautilus # File manager
    loupe # Image viewer
    decibels # Audio player
    gedit # Text editor
    pavucontrol # Audio control
    blueberry # Bluetooth control
    samba # Samba
    imagemagick # Image processing

    qt5.qtwayland
    qt6.qtwayland
  ];
}
