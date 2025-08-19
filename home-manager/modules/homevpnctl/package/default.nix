{
  config,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "homevpnctl"
(
  builtins.replaceStrings
  [
    "@configFile@"
    "@configDirectory@"
  ]
  [
    config.services.homevpnctl.configFile
    config.xdg.configHome
  ]
  (builtins.readFile ./source.sh)
)
