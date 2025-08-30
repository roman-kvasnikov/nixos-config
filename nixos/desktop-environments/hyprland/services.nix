{
  services = {
    displayManager.sddm = {
      enable = true;

      wayland.enable = true;
    };

    gvfs.enable = true; # File system integration
  };
}
