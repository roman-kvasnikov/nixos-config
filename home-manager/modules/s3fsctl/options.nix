{lib, ...}:
with lib; {
  options.services.s3fsctl = {
    enable = mkEnableOption "Mount S3 buckets via s3fs";

    buckets = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            bucket = mkOption {
              type = types.str;
              description = "S3 bucket name";
            };

            mountPoint = mkOption {
              type = types.path;
              description = "Local mount point for the bucket";
            };

            url = mkOption {
              type = types.str;
              description = "Base S3-compatible URL (e.g., https://s3.twcstorage.ru)";
            };

            endpoint = mkOption {
              type = types.str;
              description = "Endpoint for S3 (e.g., s3.twcstorage.ru)";
            };

            passwordFile = mkOption {
              type = types.path;
              description = "Path to the s3fs credentials file (format: ACCESS_KEY:SECRET_KEY)";
            };
          };
        });
      default = {};
      description = "Buckets to be mounted";
    };
  };
}
