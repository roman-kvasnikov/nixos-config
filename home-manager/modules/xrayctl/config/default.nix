{
  lib,
  config,
  ...
}: let
  xrayctlConfig = config.services.xrayctl;
in {
  config = lib.mkIf xrayctlConfig.enable {
    xdg.configFile."xray/config.example.json".source = ./config.example.json;
  };
}
