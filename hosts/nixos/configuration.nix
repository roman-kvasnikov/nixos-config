{
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/modules
    ../../nixos/packages.nix
  ];

  # Настройка LUKS
  boot.initrd.luks.devices = {
    "crypted" = {
      device = "/dev/disk/by-uuid/a6cea734-ab18-47c0-b130-e922ba9d678b"; # UUID зашифрованного раздела!
      preLVM = true; # LUKS расшифровывается ДО активации LVM
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
