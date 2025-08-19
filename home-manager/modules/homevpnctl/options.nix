{
  lib,
  config,
  pkgs,
  ...
}: {
  options.services.homevpnctl = {
    enable = lib.mkEnableOption "Home VPN L2TP/IPsec management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/homevpn/config.json";
      description = "Path to Home VPN L2TP/IPsec configuration file";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package {inherit config pkgs;};
      description = "Home VPN L2TP/IPsec management tool package";
    };
  };
}
