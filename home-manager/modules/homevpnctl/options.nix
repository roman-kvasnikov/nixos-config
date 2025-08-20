{
  lib,
  config,
  ...
}: {
  options.services.homevpnctl = {
    enable = lib.mkEnableOption "Home VPN L2TP/IPsec management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/homevpn/config.json";
      description = "Path to configuration file";
    };

    checkInterval = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Check connection interval in seconds";
    };

    enableHealthCheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable connection health checks";
    };
  };
}
