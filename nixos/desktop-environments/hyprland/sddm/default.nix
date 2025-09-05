{pkgs, ...}: {
  imports = [
    ./themes/sddm-sugar.nix
  ];

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    theme = "sddm-sugar-dark";
  };
}
