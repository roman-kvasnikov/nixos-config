{pkgs, ...}: {
  services = {
    xserver = {
      enable = false;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      xkb = {
        layout = "us,ru";
        options = "grp:ctrl_shift_toggle";
      };
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

    # xrdp = {
    #   enable = true;
    #   defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    #   openFirewall = true;
    # };
  };
}
