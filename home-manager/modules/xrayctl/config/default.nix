{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xrayctl.enable {
    xdg.configFile."xray/config.example.json".source = ./config.example.json;
  };
}
