{
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ./${hostname}/hardware-configuration.nix
    ../nixos/modules
    ./packages.nix
  ];

  system.stateVersion = version;
}
