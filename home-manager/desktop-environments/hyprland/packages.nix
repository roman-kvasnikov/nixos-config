{pkgs, ...}: {
  home.packages = with pkgs; [
    gnome-calculator
    hyprpicker
    hyprshot
  ];
}
