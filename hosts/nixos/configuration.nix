{ user, version, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ../../nixos/modules
  ];

  system.stateVersion = version;
}