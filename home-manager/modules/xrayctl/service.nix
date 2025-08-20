{
  lib,
  config,
  pkgs,
  ...
}: let
  xrayctlConfig = config.services.xrayctl;
in {
  config = lib.mkIf xrayctlConfig.enable {
    systemd.user.services.xray = {
      Unit = {
        Description = "Xray proxy service";
        Documentation = "https://xtls.github.io/";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
        PartOf = ["network-online.target"];
      };

      Service = {
        Type = "simple";

        ExecStart = "${pkgs.xray}/bin/xray run -config ${xrayctlConfig.configFile}";
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
          "PATH=${lib.makeBinPath [pkgs.jq pkgs.coreutils]}"
        ];

        # Логирование
        StandardOutput = "journal";
        StandardError = "journal";

        # Безопасность
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          "${config.xdg.configHome}/xray"
        ];

        # Network
        PrivateNetwork = false;

        # Capabilities
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."xray/.keep".text = "";
    };
  };
}
