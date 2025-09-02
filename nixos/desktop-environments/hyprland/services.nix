{
  services = {
    # udev.extraRules = ''
    #   # Hyprland display switcher rules
    #   # Запускать при подключении/отключении дисплея
    #   #ACTION=="change", KERNEL=="card[0-9]*", SUBSYSTEM=="drm", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="hyprland-display-switcher.service"
    #   #ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", KERNEL=="card[0-9]-*", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="hyprland-display-switcher.service"
    #   #ACTION=="change", SUBSYSTEM=="drm", KERNEL=="card[0-9]-DP-[0-9]", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="hyprland-display-switcher.service"
    # '';
    gvfs.enable = true; # File system integration
  };
}
