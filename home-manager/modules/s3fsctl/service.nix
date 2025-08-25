{
  lib,
  config,
  pkgs,
  ...
}: let
  s3fsctlConfig = config.services.s3fsctl;
  s3fsctl = pkgs.callPackage ./package/package.nix {inherit s3fsctlConfig config pkgs;};
in {
  config = lib.mkIf s3fsctlConfig.enable {
    systemd.user.services.s3fsctl = {
      Unit = {
        Description = "S3FS Connection Manager";
        Documentation = "S3FS management tool for mounting/unmounting S3 buckets";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;

        # Команды для управления
        ExecStart = "${s3fsctl}/bin/s3fsctl mount";
        ExecStop = "${s3fsctl}/bin/s3fsctl unmount";

        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.s3fs
            pkgs.coreutils
            pkgs.jq
            pkgs.util-linux
            pkgs.gnugrep
            pkgs.curl
          ]}"
        ];
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    xdg = {
      configFile."s3fs/README.md".source = ./README.md;
    };
  };
}
