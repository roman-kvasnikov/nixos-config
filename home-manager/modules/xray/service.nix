{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xray-user.enable {
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
        ExecStart = "${pkgs.xray}/bin/xray run -config ${config.services.xray-user.configFile}";
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
          "%h/.config/xray"
          "%h/.local/share/xray"
          "%h/.cache/xray"
        ];

        # Network
        PrivateNetwork = false;

        # Capabilities
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
      };
    };

    # Создать необходимые директории
    home.file = {
      ".config/xray/.keep".text = "";
      ".local/share/xray/.keep".text = "";
      ".cache/xray/.keep".text = "";
    };
  };
}
