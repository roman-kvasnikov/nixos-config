{
  lib,
  config,
  ...
}: {
  options.services.s3fsctl = {
    enable = lib.mkEnableOption "S3FS management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/s3fs/config.example.json";
      description = "Path to configuration file";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/s3fs/.passwd-s3fs";
      description = "Path to passwords file";
    };

    mountPoint = lib.mkOption {
      type = lib.types.path;
      default = "/home/romank/S3-TimeWeb";
      description = "Path to mount point";
    };
  };
}
