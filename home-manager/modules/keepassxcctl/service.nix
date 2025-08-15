{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.keepassxcctl.enable {
    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeePassXC password manager";
        After = ["graphical-session-pre.target"];
        PartitionOf = ["graphical-session.target"];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.keepassxc}/bin/keepassxc --pw-stdin ${config.services.keepassxcctl.database}";
        Restart = "on-failure";
        RestartSec = "3s";

        # Для чтения пароля из Secret Service
        Environment = [
          "QT_QPA_PLATFORM=xcb"
          "DISPLAY=:0"
        ];
      };
    };

    xdg.configFile."keepassxc/keepassxc.ini".text = ''
      [General]
      ConfigVersion=2
      AutoSaveAfterEveryChange=true
      AutoTypeDelay=25

      [Browser]
      Enabled=true

      [GUI]
      ApplicationTheme=dark
      TrayIconAppearance=monochrome-light

      [Security]
      LockDatabaseIdle=true
      LockDatabaseIdleSeconds=900
      LockDatabaseMinimize=false
      LockDatabaseScreenLock=true
      ClearClipboardTimeout=20

      [SSHAgent]
      Enabled=true

      [FdoSecrets]
      Enabled=true
      ShowNotification=true
    '';
  };
}
