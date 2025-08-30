{pkgs, ...}: {
  home.packages = with pkgs; [
    gnome-calculator # Calculator
    gnome-calendar # Calendar
    nautilus # File manager
    gedit # Text editor
  ];
}
