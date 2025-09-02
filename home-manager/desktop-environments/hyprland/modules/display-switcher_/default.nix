{
  lib,
  config,
  pkgs,
  ...
}: let
  hyprlandDisplaySwitcherConfig = config.services.hyprland-display-switcher;
  hyprlandDisplaySwitcher = pkgs.callPackage ./package/package.nix {inherit hyprlandDisplaySwitcherConfig config pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf hyprlandDisplaySwitcherConfig.enable {
    home.packages = [
      hyprlandDisplaySwitcher
      pkgs.coreutils
      pkgs.hyprland
    ];
  };
}
