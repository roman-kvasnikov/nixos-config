{
  home.sessionVariables = {
    # GNOME/GTK настройки
    GTK_THEME = "default-dark";

    # Wayland настройки для GNOME приложений
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11";

    # Масштабирование для HiDPI (если нужно)
    # GDK_SCALE = "1.25";
    # GDK_DPI_SCALE = "0.8";
  };
}
