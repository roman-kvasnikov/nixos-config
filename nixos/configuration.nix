{
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ../hosts/${hostname}/hardware-configuration.nix
    ./modules
    ./packages.nix
  ];

  system.stateVersion = version;
}
