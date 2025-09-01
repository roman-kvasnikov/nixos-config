{
  services = {
    udev.extraRules = ''
      # Hyprland display switcher rules
      # Запускать при подключении/отключении дисплея
      ACTION=="change", KERNEL=="card[0-9]*", SUBSYSTEM=="drm", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="hyprland-display-switcher.service"
    '';
    gvfs.enable = true; # File system integration
  };
}
