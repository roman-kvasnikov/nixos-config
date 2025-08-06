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

  services = {
    qemuGuest.enable = true;
    openssh.enable = true;
    spice-vdagentd.enable = true;
    spice-autorandr.enable = true;
  };

  system.stateVersion = version;
}
