{
  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1"; # Firefox поддержка Wayland
      NIXOS_OZONE_WL = "1"; # Chromium/Electron apps поддержка Wayland

      XDG_SESSION_TYPE = "wayland";

      MALLOC_CHECK_ = "0"; # Отключаем проверку памяти для производительности
    };
  };
}
