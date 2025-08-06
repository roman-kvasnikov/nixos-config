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

  system.stateVersion = version;
}
