{pkgs, ...}: {
  imports = [
    ./themes/sddm-sugar
  ];

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    theme = "sddm-sugar-dark";
  };
}
