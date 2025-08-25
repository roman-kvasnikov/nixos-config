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
        Description = "S3FS Connection Manager";
        Documentation = "S3FS management tool for mounting/unmounting S3 buckets";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;

        # Команды для управления
        ExecStart = "${s3fsctl}/bin/s3fsctl mount";
        ExecStop = "${s3fsctl}/bin/s3fsctl unmount";

        # Таймауты
        TimeoutStartSec = "60s";
        TimeoutStopSec = "30s";

        # Restart политика
        Restart = "on-failure";
        RestartSec = "15s";
        StartLimitBurst = 3;
        StartLimitIntervalSec = "300s";

        # Окружение - добавлен grep
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.s3fs pkgs.jq pkgs.coreutils pkgs.util-linux pkgs.gnugrep]}"
        ];

        # Уменьшенные ограничения безопасности для работы с S3FS
        PrivateTmp = true;
        NoNewPrivileges = true;

        # Логирование
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "s3fsctl";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."s3fs/.keep".text = "";
      configFile."s3fs/README.md".text = ''
        # S3FSCtl Configuration
        
        This directory contains configuration for S3FSCtl service.
        
        ## Files:
        - `config.json` - Main configuration file
        - `config.example.json` - Example configuration
        - `s3fsctl.log` - Service log file (created when s3fsctl runs)
        
        ## Security Notes:
        - Password files should have 600 permissions
        - Only use absolute paths
        - Avoid mounting in system directories
        - Logs are written to ~/.config/s3fs/s3fsctl.log
        
        ## Usage:
        ```bash
        s3fsctl mount           # Mount all configured buckets
        s3fsctl unmount         # Unmount all buckets
        s3fsctl status          # Show mount status
        s3fsctl mount bucket1   # Mount specific bucket
        s3fsctl unmount bucket1 # Unmount specific bucket
        s3fsctl test bucket1    # Test bucket configuration
        s3fsctl logs           # Show recent log entries
        ```
        
        ## SystemD Service:
        The service automatically mounts all configured buckets on login.
        - Enable: `systemctl --user enable s3fsctl.service`
        - Start: `systemctl --user start s3fsctl.service`
        - Status: `systemctl --user status s3fsctl.service`
      '';
    };
  };
}
