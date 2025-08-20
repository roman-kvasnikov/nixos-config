{
  lib,
  config,
  pkgs,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
  homevpnctlPackage = pkgs.callPackage ./package/package.nix {inherit homevpnctlConfig config pkgs;};
in {
  config = lib.mkIf homevpnctlConfig.enable {
    systemd.user.services.homevpnctl = {
      Unit = {
        Description = "Home VPN L2TP/IPsec Connection Daemon";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
        PartOf = ["network-online.target"];
      };

      Service = {
        Type = "simple";

        ExecStart = "${homevpnctlPackage}/bin/homevpnctl daemon";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        # Restart политика
        Restart = "on-failure";
        RestartSec = "30s";

        # Процессы и сигналы
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        TimeoutStopSec = "30s";

        # Окружение
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.networkmanager pkgs.jq pkgs.coreutils]}"
        ];
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
