{
  lib,
  config,
  ...
}: let
  s3fsctlConfig = config.services.s3fsctl;
in {
  config = lib.mkIf s3fsctlConfig.enable {
    xdg.configFile."s3fs/config.example.json".source = ./config.example.json;
  };
}
