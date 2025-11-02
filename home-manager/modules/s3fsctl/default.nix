{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.s3fsctl;
in {
  imports = [
    ./options.nix
    ./service.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      s3fs
      fuse3
      coreutils
    ];
  };
}
