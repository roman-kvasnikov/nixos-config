{config, ...}: {
  xdg = {
    enable = true;

    # configFile."gtk-3.0/bookmarks".force = true;

    mimeApps.enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}";
    };
  };

  home.file."${config.xdg.userDirs.templates}/NewDocument.txt".text = "";
}
