{
  services = {
    # displayManager.gdm = {
    #   enable = true;

    #   wayland = true;
    #   autoSuspend = false;
    # };

    displayManager.sddm = {
      enable = true;

      wayland.enable = true;
      autoSuspend = false;
    };
  };
}
