{
  lib,
  config,
  ...
}: {
  options.services.keepassxcctl = {
    enable = lib.mkEnableOption "KeePassXCctl autostart service";

    database = lib.mkOption {
      type = lib.types.path;
      description = "Path to KeePassXC database";
      default = "${config.xdg.configHome}/keepassxc/garbage.kdbx";
    };
  };
}
