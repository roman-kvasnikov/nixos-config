{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xrayctl.enable {
    systemd.user.services.xray = {
      Unit = {
        Description = "Xray proxy service (user)";
        Documentation = "https://xtls.github.io/";
        After = ["network.target"];
        Wants = ["network.target"];
      };

      Install = {
        WantedBy = ["default.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.xray}/bin/xray run -config ${config.services.xrayctl.configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
        RestartSec = "3s";
        KillMode = "mixed";

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
          "${config.xdg.dataHome}/xray"
          "${config.xdg.cacheHome}/xray"
        ];

        # Network
        PrivateNetwork = false;

        # Capabilities
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
      };
    };

    # Создать необходимые директории
    xdg = {
      configFile."xray/.keep".text = "";
      dataFile."xray/.keep".text = "";
      cacheFile."xray/.keep".text = "";
    };
  };
}
