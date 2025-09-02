{pkgs, ...}:
pkgs.writeShellScriptBin "restart-waybar"
(
  builtins.readFile ../scripts/restart-waybar.sh
)
