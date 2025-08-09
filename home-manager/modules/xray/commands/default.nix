{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xray-user.enable {
    home.packages = [
      (
        pkgs.writeShellScriptBin "xray-user"
        (
          builtins.replaceStrings
          [
            "@configFile@"
            "@homeDirectory@"
            "@jq@"
            "@gsettings@"
          ]
          [
            config.services.xray-user.configFile
            config.home.homeDirectory
            "${pkgs.jq}"
            "${pkgs.glib}"
          ]
          (builtins.readFile ./commands.sh)
        )
      )
    ];
  };
}
