{
  config,
  ...
}: {
  gtk.gtk3 = {
    bookmarks = [
      "file:///"
      "file://${config.home.homeDirectory}/.local"
      "file://${config.home.homeDirectory}/.config"
      "file://${config.xdg.userDirs.download}"
    ];
  };
}