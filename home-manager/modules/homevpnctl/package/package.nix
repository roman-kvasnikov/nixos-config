{
  homevpnctlConfig,
  config,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "homevpnctl"
(
  builtins.replaceStrings
  [
    "@configDirectory@"
    "@configFile@"
    "@checkInterval@"
    "@enableHealthCheck@"
  ]
  [
    "${config.xdg.configHome}/homevpn"
    homevpnctlConfig.configFile
    homevpnctlConfig.checkInterval
    homevpnctlConfig.enableHealthCheck
  ]
  (builtins.readFile ./source.sh)
)
