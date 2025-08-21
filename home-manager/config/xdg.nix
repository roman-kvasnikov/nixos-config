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

    mimeApps = {
      enable = true;

      # [Default Applications]
      # x-scheme-handler/tg=org.telegram.desktop.desktop
      # x-scheme-handler/tonsite=org.telegram.desktop.desktop
      # application/vnd.ms-publisher=org.gnome.TextEditor.desktop
      # text/plain=org.gnome.TextEditor.desktop
      # application/octet-stream=org.gnome.TextEditor.desktop
      # image/png=org.gnome.Loupe.desktop
      # image/jpeg=org.gnome.Loupe.desktop
      # image/gif=org.gnome.Loupe.desktop
      # [Added Associations]
      # x-scheme-handler/tg=org.telegram.desktop.desktop;
      # x-scheme-handler/tonsite=org.telegram.desktop.desktop;
      # application/vnd.ms-publisher=org.gnome.TextEditor.desktop;
      # text/plain=org.gnome.TextEditor.desktop;
      # application/octet-stream=org.gnome.TextEditor.desktop;
      # image/png=org.gnome.Loupe.desktop;
      # image/jpeg=org.gnome.Loupe.desktop;
      # image/gif=org.gnome.Loupe.desktop;

      defaultApplications = {
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "text/plain" = ["org.gnome.TextEditor.desktop"];
        "image/*" = ["org.gnome.Loupe.desktop"];
        "image/png" = ["org.gnome.Loupe.desktop"];
        "image/jpeg" = ["org.gnome.Loupe.desktop"];
        "image/gif" = ["org.gnome.Loupe.desktop"];
        "image/svg+xml" = ["org.gnome.Loupe.desktop"];
        "image/webp" = ["org.gnome.Loupe.desktop"];
        "image/tiff" = ["org.gnome.Loupe.desktop"];
        "image/x-xbitmap" = ["org.gnome.Loupe.desktop"];
        "image/x-xpixmap" = ["org.gnome.Loupe.desktop"];
        "image/x-xwindowdump" = ["org.gnome.Loupe.desktop"];
      };

      associations.added = {
        "application/pdf" = ["firefox.desktop"];
      };
    };
  };

  home.file."${config.xdg.userDirs.templates}/NewDocument.txt".text = "";
}
