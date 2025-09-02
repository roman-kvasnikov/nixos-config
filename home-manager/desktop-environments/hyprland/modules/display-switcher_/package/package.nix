{
  hyprlandDisplaySwitcherConfig,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "hyprland-display-switcher"
(
  builtins.replaceStrings
  [
    "@buildinMonitor@"
  ]
  [
    hyprlandDisplaySwitcherConfig.buildinMonitor
  ]
  (builtins.readFile ./source.sh)
)
