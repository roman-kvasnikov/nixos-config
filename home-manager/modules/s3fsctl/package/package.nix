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
  ]
  [
    "${config.xdg.configHome}/s3fs"
    s3fsctlConfig.configFile
  ]
  (builtins.readFile ./source.sh)
)
