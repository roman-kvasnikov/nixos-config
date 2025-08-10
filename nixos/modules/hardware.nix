{pkgs, ...}: {
  hardware = {
    # Bluetooth
    bluetooth = {
      enable = true;

      powerOnBoot = true;
      settings.General.Experimental = true;  # Для новых функций
    };

    # Современные графические драйверы
    opengl = {
      enable = true;

      # Для AMD/Intel
      extraPackages = with pkgs; [
        intel-media-driver    # Intel VAAPI
        vaapiIntel            # Старые Intel GPU
        vaapiVdpau            # NVIDIA через VDPAU
        libvdpau-va-gl        # OpenGL VDPAU
        intel-compute-runtime # Intel OpenCL
      ];
    };

    # Подсветка клавиатуры
    keyboard.qmk.enable = true;
  };
}
