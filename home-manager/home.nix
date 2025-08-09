{
  hostname,
  system,
  version,
  config,
  user,
  inputs,
  ...
}: {
  imports = [
    ./config
    ./packages.nix
    ./services.nix
    ./modules
  ];
}
