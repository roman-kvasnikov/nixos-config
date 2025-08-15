{
  lib,
  inputs,
  ...
}: {
  programs.kitty = lib.mkForce {
    enable = true;

    settings = {
      # General
      term = "xterm-kitty";
      kitty_mod = "ctrl+shift";

      # Font (будет использован из stylix)
      font_family = "Fira Code Nerd Font";
      font_size = 12.0;

      # Layout
      enabled_layouts = "tall, *";

      # Background
      background_image = "${inputs.wallpapers}/NixOS/nix-wallpaper-nineish-catppuccin-macchiato-alt.png";
      background_image_layout = "scaled";
      background_tint = "0.5";
      # background_opacity = "0.9";
      # background_blur = 32;

      # Window
      window_margin_width = 5;
      window_padding_width = 0;
      window_border_width = "1.5pt";
      remember_window_size = "no";
      initial_window_width = 1280;
      initial_window_height = 720;
      hide_window_decorations = "no";

      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_edge = "bottom";
      tab_bar_align = "left";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      # Terminal bell
      enable_audio_bell = "no";

      # OS specific tweaks (Gnome window decoration for wayland)
      linux_display_server = "x11";

      # Mouse
      mouse_hide_wait = "-1.0";
    };
  };
}
