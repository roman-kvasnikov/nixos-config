{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.services.xrayctl.enable {
    home.packages = [
      (
        pkgs.writeShellScriptBin "xrayctl"
        (
          builtins.replaceStrings
          [
            "@configFile@"
            "@homeDirectory@"
            # "@jq@"
            # "@gsettings@"
          ]
          [
            config.services.xrayctl.configFile
            config.home.homeDirectory
            # "${pkgs.jq}"
            # "${pkgs.glib}"
          ]
          (builtins.readFile ./commands.sh)
        )
      )
    ];
  };
}
