{
  environment = {
    sessionVariables = {
      # Wayland настройки
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";

      # XDG настройки
      XDG_SESSION_TYPE = "wayland";

      # Оптимизации производительности
      MALLOC_CHECK_ = "0"; # Отключаем проверку памяти
    };
  };
}