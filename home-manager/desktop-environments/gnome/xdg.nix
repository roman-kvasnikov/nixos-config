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
        "audio/mpeg" = ["org.gnome.Decibel.desktop"];
        "audio/ogg" = ["org.gnome.Decibel.desktop"];
        "audio/x-wav" = ["org.gnome.Decibel.desktop"];

        # Текстовые файлы
        "text/plain" = ["org.gnome.TextEditor.desktop"];
        "text/markdown" = ["org.gnome.TextEditor.desktop"];

        # PDF
        "application/pdf" = ["org.gnome.Evince.desktop"];

        # Архивы
        "application/zip" = ["org.gnome.FileRoller.desktop"];
        "application/x-tar" = ["org.gnome.FileRoller.desktop"];
        "application/gzip" = ["org.gnome.FileRoller.desktop"];
      };
    };
  };
}
