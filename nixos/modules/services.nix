{
  services = {
    qemuGuest.enable = true;
    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      xkb.layout = "us,ru";
      xkb.options = "grp:ctrl_shift_toggle";
    };
  };
}