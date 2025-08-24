{
  lib,
  config,
  ...
}: {
  options.services.s3fsctl = {
    enable = lib.mkEnableOption "S3FS management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/s3fs/config.json";
      description = "Path to configuration file";
    };
  };
}
