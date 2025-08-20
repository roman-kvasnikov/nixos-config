{
  lib,
  config,
  ...
}: {
  options.services.xrayctl = {
    enable = lib.mkEnableOption "Xray management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/xray/config.json";
      description = "Path to configuration file";
    };
  };
}
