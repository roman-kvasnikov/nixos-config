{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # sddm-sugar-dark
    sddm-astronaut
    libsForQt5.qt5.qtgraphicaleffects
  ];

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    theme = "astronaut";
  };
}
