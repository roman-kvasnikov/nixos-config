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
    systemd.user.services.hyprland-display-switcher = {
      Unit = {
        Description = "Hyprland Display Switcher";
        After = ["hyprland-session.target"];
        PartOf = ["hyprland-session.target"];
        Requires = ["hyprland-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher";
        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.coreutils
            pkgs.hyprland
          ]}"
        ];
      };

      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };

  # Настройка Hyprland
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher"
    ];

    # Настройки мониторов
    monitor = [
      # Основной внешний монитор
      "${hyprlandDisplaySwitcherConfig.externalMonitor}"
      # Встроенный монитор ноутбука
      "${hyprlandDisplaySwitcherConfig.buildinMonitor}"
      # Fallback правило для любых других мониторов
      "${hyprlandDisplaySwitcherConfig.fallbackMonitor}"
    ];
  };
}
