{
  lib,
  config,
  ...
}: {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf config.services.homevpnctl.enable {
    home.packages = [config.services.homevpnctl.package];
  };
}
