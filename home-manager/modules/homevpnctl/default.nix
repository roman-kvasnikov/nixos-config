{
  lib,
  config,
  pkgs,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
  homevpnctlPackage = pkgs.callPackage ./package/package.nix {inherit homevpnctlConfig config pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf homevpnctlConfig.enable {
    home.packages = [homevpnctlPackage];
  };
}
