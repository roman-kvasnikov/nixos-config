{config, pkgs, ...}: let
  vaultDir = "${config.home.homeDirectory}/Documents/ObsidianVault";

  gitSyncObsidian =
    pkgs.writeScriptBin "git-sync-obsidian" ''
      #!/bin/sh

      VAULT_DIR="${vaultDir}"

      cd $VAULT_DIR || exit 1

      git add .
      git commit -m "$(date '+%Y-%m-%d %H:%M:%S')" || exit 0
      git push
    '';
in {
  home = {
    packages = [gitSyncObsidian];
    file = {
      "${vaultDir}/.keep".text = "";
    };
  };

  systemd.user.services.git-sync-obsidian = {
    Unit = {
      Description = "Sync Obsidian Vault with GitHub";
      Wants = "git-sync-obsidian.timer";
    };
    Service = {
      ExecStart = "${gitSyncObsidian}/bin/git-sync-obsidian";
      Type = "simple";
    };
  };

  systemd.user.timers.git-sync-obsidian = {
    Unit.Description = "Run Git Sync for Obsidian Vault";
    Timer.OnCalendar = "*:0/15";
    Install.WantedBy = ["timers.target"];
  };
}
