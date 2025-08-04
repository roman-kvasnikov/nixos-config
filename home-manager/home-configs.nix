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
}
