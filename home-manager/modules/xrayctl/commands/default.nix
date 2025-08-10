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
          ]
          [
            config.services.xrayctl.configFile
            config.home.homeDirectory
          ]
          (builtins.readFile ./commands.sh)
        )
      )
    ];
  };
}
