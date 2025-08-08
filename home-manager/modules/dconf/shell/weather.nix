{lib, ...}: {
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = false;
      # Используем простой подход - через gsettings можно будет настроить вручную
      # Или попробуем этот формат:
    };
    
    # Альтернативно можно настроить через org/gnome/Weather напрямую
    "org/gnome/Weather" = {
      locations = [
        "Moscow UUWW 55.752220 37.615555"
      ];
    };
  };
}
