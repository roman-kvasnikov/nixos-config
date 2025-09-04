{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    theme = "${import ./themes/dream-plazma-theme.nix {inherit pkgs inputs;}}";
  };
}
