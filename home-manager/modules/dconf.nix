{ pkgs, ... }:

{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        accent-color = "blue";
        color-scheme = "prefer-dark";
        clock-format = "24h";
        clock-show-date = true;
        clock-show-seconds = false;
        clock-show-weekday = true;
        enable-animations = true;
        enable-hot-corners = true;
        show-battery-percentage = true;
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        center-new-windows = true;
        workspaces-only-on-primary = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        action-double-click-titlebar = "toggle-maximize";
        action-middle-click-titlebar = "none";
        action-right-click-titlebar = "menu";
        button-layout = "appmenu:minimize,maximize,close";
        mouse-button-modifier = "<Super>";
        num-workspaces = 5;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false; # enables user extensions
        enabled-extensions = with pkgs.gnomeExtensions; [
          bitcoin-markets.extensionUuid
          blur-my-shell.extensionUuid
          caffeine.extensionUuid
          clipboard-history.extensionUuid
          dash-to-dock.extensionUuid
          desktop-cube.extensionUuid
          search-light.extensionUuid
        ];
        favorite-apps = ["org.gnome.Nautilus.desktop" "brave-browser.desktop" "hiddify.desktop" "org.telegram.desktop.desktop" "org.keepassxc.KeePassXC.desktop"];
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        always-center-icons = true;
        application-counter-overrides-notifications = true;
        apply-custom-theme = false;
        apply-glossy-effect = false;
        autohide = true;
        background-opacity = 0.0;
        click-action = "minimize-or-overview";
        custom-background-color = false;
        custom-theme-customize-running-dots = false;
        custom-theme-running-dots-border-color = "rgb(0,0,0)";
        custom-theme-running-dots-border-width = 0;
        custom-theme-running-dots-color = "rgb(255,255,255)";
        custom-theme-shrink = false;
        dance-urgent-applications = true;
        dash-max-icon-size = 48;
        disable-overview-on-startup = false;
        dock-fixed = false;
        dock-position = "BOTTOM";
        extend-height = false;
        height-fraction = 0.90000000000000002;
        hide-tooltip = false;
        hot-keys = false;
        hotkeys-overlay = false;
        hotkeys-show-dock = false;
        icon-size-fixed = true;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        isolate-monitors = false;
        isolate-workspaces = false;
        middle-click-action = "launch";
        multi-monitor = false;
        preferred-monitor = -2;
        preferred-monitor-by-connector = "eDP-1";
        preview-size-scale = 0.10000000000000001;
        running-indicator-dominant-color = true;
        running-indicator-style = "DASHES";
        scroll-action = "do-nothing";
        scroll-to-focused-application = true;
        shift-click-action = "minimize";
        shift-middle-click-action = "launch";
        show-apps-always-in-the-edge = false;
        show-apps-at-top = false;
        show-favorites = true;
        show-icons-emblems = true;
        show-icons-notifications-counter = true;
        show-mounts-network = false;
        show-show-apps-button = true;
        show-trash = false;
        show-windows-preview = true;
        transparency-mode = "DYNAMIC";
        unity-backlit-items = false;
        workspace-agnostic-urgent-windows = true;
      };
      "org/gnome/shell/extensions/search-light" = {
        animation-speed = 100.0;
        background-color = "(0.0, 0.0, 0.0, 0.49333333969116211)";
        blur-background = false;
        blur-brightness = 0.59999999999999998;
        blur-sigma = 30.0;
        border-radius = 1.28125;
        border-thickness = 2;
        entry-font-size = 1;
        monitor-count = 1;
        preferred-monitor = 0;
        scale-height = 0.10000000000000001;
        scale-width = 0.10000000000000001;
        shortcut-search = [ "<Super>R" ];
        show-panel-icon = false;
        window-effect = 0;
      };
      "org/gnome/shell/extensions/bitcoin-markets" = {
      first-run = false;
      indicators = '''
        [
          {
            "api": "bybit",
            "base": "GALA",
            "quote": "USDT",
            "attribute": "last",
            "show_change": true,
            "format": "{bs} {v5} $"
          },
          {
            "api": "bybit",
            "base": "BTC",
            "quote": "USDT",
            "attribute": "last",
            "show_change": true,
            "format": "{btc} {v0} $"
          }
        ]''';
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Brave Browser";
        command = "brave";
        binding = "<Super>B";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Calculator";
        command = "calc";
        binding = "<Super>C";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "Nautilus";
        command = "nautilus";
        binding = "<Super>E";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "Warp";
        command = "warp-terminal";
        binding = "<Super>Return";
      };
    };
  };
}
