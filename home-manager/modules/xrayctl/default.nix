{
  lib,
  config,
  pkgs,
  ...
}: let
  xrayctlConfig = config.services.xrayctl;
  xrayctlPackage = pkgs.callPackage ./package/package.nix {inherit xrayctlConfig config pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf xrayctlConfig.enable {
    home.packages = [pkgs.xray xrayctlPackage];
  };
}
