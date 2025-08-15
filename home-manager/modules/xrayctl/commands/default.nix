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
            "@configDirectory@"
          ]
          [
            config.services.xrayctl.configFile
            config.home.homeDirectory
            config.xdg.configHome
          ]
          (builtins.readFile ./commands.sh)
        )
      )
    ];
  };
}
