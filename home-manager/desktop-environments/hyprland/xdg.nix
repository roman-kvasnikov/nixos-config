{config, ...}: {
  xdg = {
    enable = true;

    # MIME ассоциации для GNOME
    mimeApps = {
      enable = true;

      defaultApplications = {
        # Веб-браузер
        "text/html" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];
        "x-scheme-handler/about" = ["brave-browser.desktop"];
        "x-scheme-handler/unknown" = ["brave-browser.desktop"];

        # Файловый менеджер
        "inode/directory" = ["nautilus.desktop"];

        # Изображения
        # "image/jpeg" = ["org.gnome.Loupe.desktop"];
        # "image/png" = ["org.gnome.Loupe.desktop"];
        # "image/gif" = ["org.gnome.Loupe.desktop"];
        # "image/webp" = ["org.gnome.Loupe.desktop"];

        # Видео
        "video/mp4" = ["vlc.desktop"];
        "video/x-msvideo" = ["vlc.desktop"];
        "video/quicktime" = ["vlc.desktop"];

        # Аудио
        # "audio/mpeg" = ["org.gnome.Decibel.desktop"];
        # "audio/ogg" = ["org.gnome.Decibel.desktop"];
        # "audio/x-wav" = ["org.gnome.Decibel.desktop"];

        # Текстовые файлы
        "text/plain" = ["gedit.desktop"];
        "text/markdown" = ["gedit.desktop"];

        # PDF
        "application/pdf" = ["evince.desktop"];

        # Архивы
        "application/zip" = ["file-roller.desktop"];
        "application/x-tar" = ["file-roller.desktop"];
        "application/gzip" = ["file-roller.desktop"];
      };
    };

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
