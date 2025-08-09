{
  config,
  ...
}: {
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}";
      download = "${config.home.homeDirectory}/Downloads";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}";
      documents = "${config.home.homeDirectory}/Documents";
      music = "${config.home.homeDirectory}";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };

    configFile."gtk-3.0/bookmarks".force = true;
  };

  home.file."${config.xdg.userDirs.templates}/NewDocument.txt".text = "";
}