{config, ...}: {
  xdg = {
    mimeApps = {
      defaultApplications = {
        # Веб-браузер
        "text/html" = ["brave-browser.desktop"];
        "x-scheme-handler/http" = ["brave-browser.desktop"];
        "x-scheme-handler/https" = ["brave-browser.desktop"];
        "x-scheme-handler/about" = ["brave-browser.desktop"];
        "x-scheme-handler/unknown" = ["brave-browser.desktop"];

        # Файловый менеджер
        "inode/directory" = ["org.gnome.Nautilus.desktop"];

        # Изображения
        "image/jpeg" = ["org.gnome.Loupe.desktop"];
        "image/png" = ["org.gnome.Loupe.desktop"];
        "image/gif" = ["org.gnome.Loupe.desktop"];
        "image/webp" = ["org.gnome.Loupe.desktop"];

        # Видео
        "video/mp4" = ["vlc.desktop"];
        "video/x-msvideo" = ["vlc.desktop"];
        "video/quicktime" = ["vlc.desktop"];

        # Аудио
        "audio/mpeg" = ["org.gnome.Decibels.desktop"];
        "audio/ogg" = ["org.gnome.Decibels.desktop"];
        "audio/x-wav" = ["org.gnome.Decibels.desktop"];

        # Текстовые файлы
        "text/plain" = ["org.gnome.gedit.desktop"];
        "text/markdown" = ["org.gnome.gedit.desktop"];

        # PDF
        "application/pdf" = ["org.gnome.Evince.desktop"];

        # Архивы
        "application/zip" = ["file-roller.desktop"];
        "application/x-tar" = ["file-roller.desktop"];
        "application/gzip" = ["file-roller.desktop"];
      };
    };
  };
}
