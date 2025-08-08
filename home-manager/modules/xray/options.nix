{lib, config, ...}: {
  # Опции для настройки Xray сервиса
  options.services.xray-user = {
    enable = lib.mkEnableOption "Xray user service";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.config/xray/config.json";
      description = "Path to Xray configuration file";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["debug" "info" "warning" "error" "none"];
      default = "info";
      description = "Log level for Xray";
    };
  };
}