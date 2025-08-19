{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.homevpnctl.enable {
    systemd.user.services.homevpnctl = {
      Unit = {
        Description = "Home VPN L2TP/IPsec Connection";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Install = {
        WantedBy = ["default.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${config.services.homevpnctl.package}/bin/homevpnctl start";
        ExecStop = "${config.services.homevpnctl.package}/bin/homevpnctl stop";
        Restart = "on-failure";
        RestartSec = "10s";
        KillMode = "mixed";
      };
    };

    xdg = {
      configFile."homevpn/.keep".text = "";
    };
  };
}
