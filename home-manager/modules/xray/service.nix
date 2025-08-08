{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.xray-user;
in {
  config = lib.mkIf cfg.enable {
    # Пользовательский systemd service для Xray
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
        ExecStart = "${pkgs.xray}/bin/xray run -config ${cfg.configFile}";
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