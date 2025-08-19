{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.homevpnctl.enable {
    xdg.configFile."homevpn/config.example.json".source = ./config.example.json;
  };
}
