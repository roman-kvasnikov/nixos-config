{pkgs, ...}: {
  hardware = {
    bluetooth = {
      enable = true;

      powerOnBoot = true;
      settings.General.Experimental = true; # Для новых функций
    };

    graphics = {
      enable = true;

      # Для AMD/Intel
      extraPackages = with pkgs; [
        intel-media-driver # Intel VAAPI
        intel-vaapi-driver # Intel VAAPI
        libva-vdpau-driver # NVIDIA через VDPAU
        libvdpau-va-gl # OpenGL VAAPI
        libva # VAAPI
        intel-compute-runtime # Intel OpenCL
        mesa
      ];
    };

    # Подсветка клавиатуры
    # keyboard.qmk.enable = true;
  };
}
