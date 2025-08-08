{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.xray-user;
in {
  # Опции для настройки Xray сервиса
  options.services.xray-user = {
    enable = lib.mkEnableOption "Xray user service";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.config/xray/config.json";
      description = "Path to Xray configuration file";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["debug" "info" "warning" "error" "none"];
      default = "info";
      description = "Log level for Xray";
    };
  };

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

    # Базовая конфигурация (если файла не существует)
    home.file.".config/xray/config.json" = lib.mkIf (!builtins.pathExists cfg.configFile) {
      text = builtins.toJSON {
        log = {
          loglevel = cfg.logLevel;
          access = "${config.home.homeDirectory}/.local/share/xray/access.log";
          error = "${config.home.homeDirectory}/.local/share/xray/error.log";
        };

        # Пример простой конфигурации SOCKS прокси
        inbounds = [{
          port = 1080;
          listen = "127.0.0.1";
          protocol = "socks";
          settings = {
            auth = "noauth";
            udp = true;
          };
          tag = "socks-in";
        }];

        outbounds = [{
          protocol = "freedom";
          settings = {};
          tag = "freedom-out";
        }];

        routing = {
          rules = [{
            type = "field";
            inboundTag = [ "socks-in" ];
            outboundTag = "freedom-out";
          }];
        };
      };
    };

    # Скрипты управления
    home.packages = [
      (pkgs.writeShellScriptBin "xray-user" ''
        #!/usr/bin/env bash
        case "$1" in
          start)
            systemctl --user start xray
            echo "Xray service started"
            ;;
          stop)
            systemctl --user stop xray
            echo "Xray service stopped"
            ;;
          restart)
            systemctl --user restart xray
            echo "Xray service restarted"
            ;;
          status)
            systemctl --user status xray
            ;;
          logs)
            journalctl --user -u xray -f
            ;;
          enable)
            systemctl --user enable xray
            echo "Xray service enabled for autostart"
            ;;
          disable)
            systemctl --user disable xray
            echo "Xray service disabled from autostart"
            ;;
          *)
            echo "Usage: xray-user {start|stop|restart|status|logs|enable|disable}"
            exit 1
            ;;
        esac
      '')
    ];
  };
}
