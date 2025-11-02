{
  lib,
  config,
  pkgs,
  user,
  ...
}:
with lib; let
  cfg = config.services.s3fsctl;
in {
  config = mkIf cfg.enable {
    systemd.user.services = mkMerge (mapAttrsToList (name: bucketCfg: let
        serviceName = "s3fsctl-${name}";
        mountPoint = bucketCfg.mountPoint;
      in {
        ${serviceName} = {
          Unit = {
            Description = "S3FS bucket \"${name}\" Connection Manager";
            After = ["network-online.target"];
            Wants = ["network-online.target"];
          };

          Service = {
            Type = "oneshot";
            RemainAfterExit = true;

            Environment = "PATH=${makeBinPath (with pkgs; [
              s3fs
              fuse3
              coreutils
            ])}";

            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";

            ExecStart = ''
              ${pkgs.s3fs}/bin/s3fs \
                ${bucketCfg.bucket} ${mountPoint} \
                -o url=${bucketCfg.url} \
                -o endpoint=${bucketCfg.endpoint} \
                -o use_path_request_style \
                -o umask=077 \
                -o passwd_file=${bucketCfg.passwordFile}
            '';

            ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountPoint}";
          };

          Install = {
            WantedBy = ["default.target"];
          };
        };
      })
      cfg.buckets);
  };
}
