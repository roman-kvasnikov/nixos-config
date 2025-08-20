{
  xrayctlConfig,
  config,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "xrayctl"
(
  builtins.replaceStrings
  [
    "@configDirectory@"
    "@configFile@"
  ]
  [
    "${config.xdg.configHome}/xray"
    xrayctlConfig.configFile
  ]
  (builtins.readFile ./source.sh)
)
