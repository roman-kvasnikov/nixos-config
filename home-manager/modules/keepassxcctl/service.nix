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
        ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized --pw-stdin ${config.services.keepassxcctl.database}";
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
      HideWindowOnCopy=true
      MinimizeAfterUnlock=true
      MinimizeOnOpenUrl=true
      AutoSaveAfterEveryChange=true
      AutoTypeDelay=25
      StartMinimized=true
      SingleInstance=true

      [GUI]
      MinimizeOnStartup=false
      MinimizeOnClose=true
      ApplicationTheme=dark
      TrayIconAppearance=monochrome-light

      [Security]
      ClearClipboardTimeout=20
      LockDatabaseIdle=false
      LockDatabaseIdleSeconds=900
      LockDatabaseMinimize=false
      LockDatabaseScreenLock=true

      [Browser]
      Enabled=true

      [SSHAgent]
      Enabled=true

      [FdoSecrets]
      Enabled=true
      ShowNotification=false
      ConfirmAccessItem=false
    '';
  };
}
