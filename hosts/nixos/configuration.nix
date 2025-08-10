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

  services.openssh = {
    enable = false;
    settings = {
      X11Forwarding = false;
    };
  };

  system.stateVersion = version;
}
