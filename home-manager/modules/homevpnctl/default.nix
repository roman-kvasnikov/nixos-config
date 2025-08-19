{
  lib,
  config,
  ...
}: {
  imports = [
    ./options.nix
    ./service.nix
    ./config
    ./package
  ];

  config = lib.mkIf config.services.homevpnctl.enable {
    home.packages = [config.services.homevpnctl.package];
  };
}
