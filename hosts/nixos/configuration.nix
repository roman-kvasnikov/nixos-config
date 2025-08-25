{
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
      };

      systemd-boot = {
        enable = false;
        configurationLimit = 10; # 10 boot entries
      };

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 10;
        default = "saved"; # Запоминать последний выбор
      };
    };

    initrd.luks.devices = {
      "crypted" = {
        device = "/dev/disk/by-uuid/a6cea734-ab18-47c0-b130-e922ba9d678b"; # UUID зашифрованного раздела!
        preLVM = true; # LUKS расшифровывается ДО активации LVM
      };
    };
  };

  services.openssh = {
    enable = false;
    settings = {
      X11Forwarding = false;
    };
  };

  system.stateVersion = version;
}
