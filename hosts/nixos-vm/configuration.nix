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
  };

  services = {
    qemuGuest.enable = true;
    openssh.enable = true;
    spice-vdagentd.enable = true;
    spice-autorandr.enable = true;
  };

  system.stateVersion = version;
}
