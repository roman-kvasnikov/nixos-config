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
        "inode/directory" = ["nautilus.desktop"];

        # Изображения
        "image/jpeg" = ["loupe.desktop"];
        "image/png" = ["loupe.desktop"];
        "image/gif" = ["loupe.desktop"];
        "image/webp" = ["loupe.desktop"];

        # Видео
        "video/mp4" = ["vlc.desktop"];
        "video/x-msvideo" = ["vlc.desktop"];
        "video/quicktime" = ["vlc.desktop"];

        # Аудио
        "audio/mpeg" = ["decibels.desktop"];
        "audio/ogg" = ["decibels.desktop"];
        "audio/x-wav" = ["decibels.desktop"];

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
  };
}
