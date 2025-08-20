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
    "${toString homevpnctlConfig.checkInterval}"
    "${toString homevpnctlConfig.enableHealthCheck}"
  ]
  (builtins.readFile ./source.sh)
)
