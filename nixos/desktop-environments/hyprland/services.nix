{
  services = {
    # GDM display manager с Wayland
    displayManager.gdm = {
      enable = true;
      wayland = true; # Включить Wayland по умолчанию
      autoSuspend = false; # Для single-user системы
    };
  };
}
