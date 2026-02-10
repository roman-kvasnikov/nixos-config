{
  lib,
  config,
  pkgs,
  ...
}: let
  xrayctlConfig = config.services.xrayctl;
  xrayctl = pkgs.callPackage ./package/package.nix {inherit xrayctlConfig config pkgs;};
  shared = pkgs.callPackage ../.shared {};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf xrayctlConfig.enable {
    home.packages =
      shared.home.packages
      ++ [
        pkgs.xray
        xrayctl
        pkgs.jq
        pkgs.coreutils
        pkgs.glib # gsettings
        pkgs.gsettings-desktop-schemas
        pkgs.systemd
        pkgs.gnugrep
        pkgs.gnused
      ];
  };
}
