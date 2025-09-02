{pkgs, ...}:
pkgs.writeShellScriptBin "waybar-restart"
(
  builtins.readFile ./source.sh
)
