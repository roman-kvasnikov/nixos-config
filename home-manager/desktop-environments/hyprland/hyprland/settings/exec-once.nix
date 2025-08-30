{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "waybar"
      "mako"
      "hyprpaper"
      "hypridle"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
      "wl-clip-persist --clipboard regular"
      # "[workspace 1 silent] $browser"
      # "[workspace 2 silent] whatsapp-electron"
      # "[workspace 3 silent] telegram-desktop"
      "[workspace 5 silent] keepassxc"
    ];
  };
}
