{
  pkgs,
  lib,
  config,
  ...
}: let
  keepassxcctlConfig = config.services.keepassxcctl;
in {
  config = lib.mkIf keepassxcctlConfig.enable {
    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeePassXC password manager";
        After = ["graphical-session-pre.target"];
        PartitionOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized --pw-stdin ${keepassxcctlConfig.database}";
        Restart = "on-failure";
        RestartSec = "3s";

        # Для чтения пароля из Secret Service
        Environment = [
          "QT_QPA_PLATFORM=xcb"
          "DISPLAY=:0"
        ];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    xdg = {
      configFile."keepassxc/keepassxc.ini".source = ./keepassxc.ini;
    };
  };
}
