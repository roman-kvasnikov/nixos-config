{
  lib,
  config,
  ...
}: {
  options.services.xrayctl = {
    enable = lib.mkEnableOption "Xrayctl management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.config/xray/config.json";
      description = "Path to Xray configuration file";
    };
  };
}
