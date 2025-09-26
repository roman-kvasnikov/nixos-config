{
  lib,
  config,
  pkgs,
  ...
}: let
  xrayctlConfig = config.services.xrayctl;
  xrayctl = pkgs.callPackage ./package/package.nix {inherit xrayctlConfig config pkgs;};
  shared = pkgs.callPackage ../.shared {};
in {
  config = lib.mkIf xrayctlConfig.enable {
    systemd.user.services.xray = {
      Unit = {
        Description = "Xray Service";
        Documentation = "https://xtls.github.io/";
        After = ["network-online.target" "nss-lookup.target"];
        Wants = ["network-online.target" "nss-lookup.target"];
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
          "PATH=${lib.makeBinPath (
            shared.home.packages
            ++ [
              pkgs.jq
              pkgs.coreutils
              pkgs.glib # gsettings
              pkgs.systemd
              pkgs.gnugrep
              pkgs.gnused
            ]
          )}"
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

    systemd.user.services.xrayctl = {
      Unit = {
        Description = "Xrayctl management tool";
        After = ["xray.service"];
        Requires = ["xray.service"];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true; # Сохранить состояние "active" после выполнения

        ExecStart = "${xrayctl}/bin/xrayctl global-enable";
        ExecStop = "${xrayctl}/bin/xrayctl global-disable";

        # Restart политика
        Restart = "on-failure";
        RestartSec = "10s";

        # Окружение
        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.jq
            pkgs.coreutils
            pkgs.glib # gsettings
            pkgs.systemd
            pkgs.gnugrep
            pkgs.gnused
          ]}"
        ];
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."xray/README.md".source = ./README.md;
    };
  };
}
