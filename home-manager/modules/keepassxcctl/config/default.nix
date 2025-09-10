{
  lib,
  config,
  ...
}: let
  keepassxcctlConfig = config.services.keepassxcctl;
in {
  config = lib.mkIf keepassxcctlConfig.enable {
    xdg.configFile."keepassxc/keepassxc.ini".source = ./keepassxc.ini;
  };
}
