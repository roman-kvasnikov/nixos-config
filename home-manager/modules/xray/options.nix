{
  lib,
  config,
  ...
}: {
  options.services.xray-user = {
    enable = lib.mkEnableOption "Xray user service";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.config/xray/config.json";
      description = "Path to Xray configuration file";
    };
  };
}
