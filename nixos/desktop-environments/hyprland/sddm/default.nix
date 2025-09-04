{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];

  # imports = [inputs.sddm-sugar-candy-nix.nixosModules.default];

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    # sugarCandyNix = {
    #   enable = true;

    #   settings = {
    #     Background = "${inputs.wallpapers}/banff-day.jpg";
    #     FormPosition = "left";
    #     HaveFormBackground = true;
    #     PartialBlur = true;
    #   };
    # };

    theme = "${import ./themes/sddm-sugar-dark.nix {inherit pkgs inputs;}}";
  };
}
