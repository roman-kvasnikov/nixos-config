{
  user,
  version,
  hostname,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/modules
    ./packages.nix
  ];

  system.stateVersion = version;
}
