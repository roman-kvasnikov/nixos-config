{
  lib,
  config,
  pkgs,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
  homevpnctl = pkgs.callPackage ./package/package.nix {inherit homevpnctlConfig config pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf homevpnctlConfig.enable {
    home.packages = [homevpnctl];
  };
}
