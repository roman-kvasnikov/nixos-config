{config, pkgs, ...}: let
  vaultDir = "${config.home.homeDirectory}/Documents/ObsidianVault";

  repoUrl = "git@github.com:roman-kvasnikov/obsidian-vault.git";

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
  };

  # Автоматический клон репозитория при развертывании
  home.activation.cloneObsidianVault = config.lib.dag.entryAfter ["writeBoundary"] ''
    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ~/.ssh/id_ed25519"

    if [ ! -d "${vaultDir}/.git" ]; then
      echo "Клонирование Obsidian Vault из ${repoUrl}..."
      run rm -rf "${vaultDir}"
      run mkdir -p "${vaultDir}"
      run ${pkgs.git}/bin/git clone "${repoUrl}" "${vaultDir}"
      echo "Obsidian Vault успешно склонирован!"
    else
      echo "Obsidian Vault уже существует, пропускаем клонирование."
      cd "${vaultDir}"
      run ${pkgs.git}/bin/git pull
      echo "Obsidian Vault обновлен."
    fi
  '';

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
