{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xrayctl.enable {
    home.file.".config/xray/config.example.json" = {
      source = ./config.example.json;
    };
  };
}
