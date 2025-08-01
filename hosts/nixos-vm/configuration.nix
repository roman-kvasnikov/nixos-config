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
    ./packages.nix
  ];

  system.stateVersion = version;
}
