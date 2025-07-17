{ stateVersion, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ../../nixos/modules
  ];

  system.stateVersion = stateVersion;
}