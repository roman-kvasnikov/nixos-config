{pkgs, ...}: {
  # XDG портал для интеграции приложений с системой
  xdg.portal = {
    enable = true;

    wlr.enable = false; # Отключаем wlroots портал для GNOME

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];

    config = {
      common = {
        default = "hyprland";
        "org.freedesktop.impl.portal.FileChooser" = "hyprland";
        "org.freedesktop.impl.portal.AppChooser" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        "org.freedesktop.impl.portal.Wallpaper" = "hyprland";
      };
    };
  };
}
