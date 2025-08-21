{
  lib,
  config,
  pkgs,
  ...
}: let
  s3fsctlConfig = config.services.s3fsctl;
  s3fsctl = pkgs.callPackage ./package/package.nix {inherit s3fsctlConfig config pkgs;};
in {
  config = lib.mkIf s3fsctlConfig.enable {
    systemd.user.services.s3fsctl = {
      Unit = {
        Description = "S3FS Connection Daemon";
        After = ["network-online.target"];
      };

      Service = {
        Type = "simple";

        ExecStart = "${s3fsctl}/bin/s3fsctl mount";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${s3fsctl}/bin/s3fsctl unmount";

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
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."s3fs/.keep".text = "";
    };
  };
}
