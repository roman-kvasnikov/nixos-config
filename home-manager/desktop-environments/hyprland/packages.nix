{pkgs, ...}: {
  home.packages = with pkgs; [
    gnome-calculator # Calculator
    nautilus # File manager
    gedit # Text editor
  ];
}
