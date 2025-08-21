{
  s3fsctlConfig,
  config,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "s3fsctl"
(
  builtins.replaceStrings
  [
    "@configDirectory@"
    "@configFile@"
    "@passwordFile@"
    "@mountPoint@"
  ]
  [
    "${config.xdg.configHome}/s3fs"
    s3fsctlConfig.configFile
    s3fsctlConfig.passwordFile
    s3fsctlConfig.mountPoint
  ]
  (builtins.readFile ./source.sh)
)
