{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.services.homevpnctl.enable {
    systemd.user.services.homevpnctl = {
      Unit = {
        Description = "Home VPN L2TP/IPsec Connection";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${config.services.homevpnctl.package}/bin/homevpnctl enable";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
        RestartSec = "10s";
        KillMode = "mixed";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."homevpn/.keep".text = "";
    };
  };
}
