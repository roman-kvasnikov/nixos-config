{pkgs, ...}: {
  hardware = {
    graphics = {
      enable = true;

      # Для AMD/Intel
      extraPackages = with pkgs; [
        intel-media-driver # Intel VAAPI
        vaapiIntel # Intel VAAPI
        libvdpau-va-gl # OpenGL VAAPI
        libva # VAAPI
        vaapiVdpau # NVIDIA через VDPAU
        intel-compute-runtime # Intel OpenCL
        mesa
      ];
    };
  };
}
