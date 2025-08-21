{
  lib,
  config,
  pkgs,
  ...
}: let
  s3fsctlConfig = config.services.s3fsctl;
  s3fsctl = pkgs.callPackage ./package/package.nix {inherit s3fsctlConfig config pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf s3fsctlConfig.enable {
    home.packages = [pkgs.s3fs s3fsctl];
  };
}
