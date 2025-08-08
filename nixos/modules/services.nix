{pkgs, ...}: {
  services = {
    xserver = {
      enable = false;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    gnome.gnome-keyring.enable = true;
  };
}
