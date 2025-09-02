{
  lib,
  config,
  pkgs,
  ...
}: let
  hyprlandDisplaySwitcherConfig = config.services.hyprland-display-switcher;
  hyprlandDisplaySwitcher = pkgs.callPackage ./package/package.nix {inherit hyprlandDisplaySwitcherConfig config pkgs;};
in {
  config = lib.mkIf hyprlandDisplaySwitcherConfig.enable {
    systemd.user.paths.hyprland-display-switcher = {
      Unit.Description = "Monitor for display changes";
      Path.PathChanged = "/sys/class/drm";
      Install.WantedBy = ["graphical-session.target"];
    };

    systemd.user.services.hyprland-display-switcher = {
      Unit.Description = "Hyprland display change handler";
      Service = {
        Type = "oneshot";
        ExecStart = "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher";
      };
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher"
      ];
    };
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "${hyprlandDisplaySwitcherConfig.builtinMonitor}"
      "${hyprlandDisplaySwitcherConfig.externalMonitor}"
      "${hyprlandDisplaySwitcherConfig.fallbackMonitor}"
    ];
  };
}
