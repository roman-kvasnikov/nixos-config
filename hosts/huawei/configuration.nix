{
  inputs,
  pkgs,
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      systemd-boot = {
        enable = false;
      };

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 10;
        default = "saved"; # Запоминать последний выбор
        theme = inputs.nixos-grub-themes.packages.${system}.nixos;
      };
    };

    initrd.luks.devices = {
      "crypted" = {
        device = "/dev/nvme0n1p9"; # UUID зашифрованного раздела!
        preLVM = true; # LUKS расшифровывается ДО активации LVM
      };
    };
  };

  environment.systemPackages = with pkgs; [
    os-prober
  ];

  services.openssh = {
    enable = false;
    settings = {
      X11Forwarding = false;
    };
  };

  system.stateVersion = version;
}
