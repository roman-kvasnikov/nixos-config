{pkgs, ...}: {
  boot = {
    loader = {
      # systemd-boot is the default loader for NixOS
      systemd-boot.enable = true;

      # grub is the default loader for NixOS
      # grub = {
      #   enable = true;
      #   efiSupport = true;
      #   device = "nodev";
      #   useOSProber = true;
      # };

      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;
  };
}
