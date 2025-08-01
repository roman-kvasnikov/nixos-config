{config, user, ...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${user.dirs.home}";
    download = "${user.dirs.home}/Downloads";
    templates = "${user.dirs.home}/Templates";
    publicShare = "${user.dirs.home}";
    documents = "${user.dirs.home}/Documents";
    music = "${user.dirs.home}";
    pictures = "${user.dirs.home}/Pictures";
    videos = "${user.dirs.home}/Videos";
  };

  gtk.gtk3 = {
    bookmarks = [
      "file:///"
      "file://${user.dirs.local}"
      "file://${user.dirs.config}"
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.download}"
      "file://${user.dirs.nixos-config} Nixos"
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
