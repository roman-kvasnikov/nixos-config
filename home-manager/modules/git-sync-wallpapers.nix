{config, pkgs, inputs, ...}: let
  inherit (inputs) wallpapers;

  wallpapersDir = "${config.home.homeDirectory}/Pictures/Wallpapers";

  repoUrl = wallpapers.url;

  gitSyncWallpapers =
    pkgs.writeScriptBin "git-sync-wallpapers" ''
      #!/bin/sh

      WALLPAPERS_DIR="${wallpapersDir}"

      cd $WALLPAPERS_DIR || exit 1

      git add .
      git commit -m "$(date '+%Y-%m-%d %H:%M:%S')" || exit 0
      git push
    '';
in {
  home = {
    packages = [gitSyncWallpapers];
  };

  # Автоматический клон репозитория при развертывании
  home.activation.cloneWallpapers = config.lib.dag.entryAfter ["writeBoundary"] ''
    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i ~/.ssh/id_ed25519"

    if [ ! -d "${wallpapersDir}/.git" ]; then
      echo "Клонирование Wallpapers из ${repoUrl}..."
      run rm -rf "${wallpapersDir}"
      run mkdir -p "${wallpapersDir}"
      run ${pkgs.git}/bin/git clone "${repoUrl}" "${wallpapersDir}"
      echo "Wallpapers успешно склонирован!"
    else
      echo "Wallpapers уже существует, пропускаем клонирование."
      cd "${wallpapersDir}"
      run ${pkgs.git}/bin/git pull
      echo "Wallpapers обновлен."
    fi
  '';

  systemd.user.services.git-sync-wallpapers = {
    Unit = {
      Description = "Sync Wallpapers with GitHub";
      Wants = "git-sync-wallpapers.timer";
    };
    Service = {
      ExecStart = "${gitSyncWallpapers}/bin/git-sync-wallpapers";
      Type = "simple";
    };
  };

  systemd.user.timers.git-sync-wallpapers = {
    Unit.Description = "Run Git Sync for Wallpapers";
    Timer.OnCalendar = "*:0/15";
    Install.WantedBy = ["timers.target"];
  };
}
