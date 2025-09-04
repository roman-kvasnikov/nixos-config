{config, ...}: {
  gtk = {
    enable = true;

    gtk3 = {
      bookmarks = [
        "file:///"
        "file://${config.xdg.dataHome} .local"
        "file://${config.xdg.configHome}"
        "file://${config.xdg.userDirs.download}"
      ];
    };
  };
}
