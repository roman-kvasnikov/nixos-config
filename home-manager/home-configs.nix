{config, user, ...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "\${HOME}";
    download = "\${HOME}/Downloads";
    templates = "\${HOME}/Templates";
    publicShare = "\${HOME}";
    documents = "\${HOME}/Documents";
    music = "\${HOME}";
    pictures = "\${HOME}/Pictures";
    videos = "\${HOME}/Videos";
  };

  gtk.gtk3 = {
    bookmarks = [
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.download}"
      # "file://${config.services.syncthing.settings.folders."sync".path}"
      # "file://${config.varden.flakeDir}"
    ];
  };

  # home.file = {
    # ".config/user-dirs.dirs".force = true;
  #   ".config/user-dirs.dirs" = {
  #     force = true;
  #     text = ''
  #       XDG_DESKTOP_DIR="$HOME/"
  #       XDG_DOWNLOAD_DIR="$HOME/Downloads"
  #       XDG_TEMPLATES_DIR="$HOME/Templates"
  #       XDG_PUBLICSHARE_DIR="$HOME/"
  #       XDG_DOCUMENTS_DIR="$HOME/Documents"
  #       XDG_MUSIC_DIR="$HOME/"
  #       XDG_PICTURES_DIR="$HOME/Pictures"
  #       XDG_VIDEOS_DIR="$HOME/Videos"
  #     '';
  #   };

    # ".config/gtk-3.0/bookmarks" = {
    #   force = true;
    #   text = ''
    #     file:/// /
    #     file:///home/${user.name}/.local .local
    #     file:///home/${user.name}/.config .config
    #     file:///home/${user.name}/Documents
    #     file:///home/${user.name}/Downloads
    #   '';
    # };
  # };
}
