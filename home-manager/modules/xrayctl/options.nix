{
  lib,
  config,
  ...
}: {
  options.services.xrayctl = {
    enable = lib.mkEnableOption "Xrayctl management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/xray/config.json";
      description = "Path to Xray configuration file";
    };
  };
}
