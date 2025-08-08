{config, ...}: {
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

  gtk.gtk3 = {
    bookmarks = [
      "file:///"
      "file://${config.home.homeDirectory}/.local"
      "file://${config.home.homeDirectory}/.config"
      "file://${config.xdg.userDirs.documents}"
      "file://${config.xdg.userDirs.download}"
      "file://${config.home.homeDirectory}/.config/nixos NixOS"
    ];
  };

  home.file."${config.xdg.userDirs.templates}/NewDocument.txt".text = "";
  
  # Включить Xray пользовательский сервис
  services.xray-user = {
    enable = true;   # Включен - предоставляет xray-user команду
    logLevel = "info";
  };
}
