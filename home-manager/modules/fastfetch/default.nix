{
  lib,
  config,
  ...
}: {
  programs.fastfetch = lib.mkForce {
    enable = true;

    settings = {
      logo = {
        source = "${config.xdg.configHome}/nixos/home-manager/modules/fastfetch/nixos-logo.png";
        height = 22;
        padding = {
          top = 0;
          left = 2;
          right = 2;
        };
      };

      display = {
        separator = "  ";
      };

      modules = [
        # Title
        {
          type = "title";
          format = "{#1}╭──────────────── {#}{user-name-colored} ────────────────";
        }
        # System Information
        {
          type = "custom";
          format = "{#1}│ {#}System Information:";
        }
        {
          type = "os";
          key = "{#separator}│  {#keys}󰍹 OS:      ";
        }
        {
          type = "kernel";
          key = "{#separator}│  {#keys}󰒋 Kernel:  ";
        }
        {
          type = "packages";
          key = "{#separator}│  {#keys}󰏖 Packages:";
          format = "{all}";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Desktop Environment
        {
          type = "custom";
          format = "{#1}│ {#}Desktop Environment:";
        }
        {
          type = "de";
          key = "{#separator}│  {#keys}󰧨 DE:      ";
        }
        {
          type = "wm";
          key = "{#separator}│  {#keys}󱂬 WM:      ";
        }
        {
          type = "wmtheme";
          key = "{#separator}│  {#keys}󰉼 Theme:   ";
        }
        {
          type = "display";
          key = "{#separator}│  {#keys}󰹑 Display: ";
        }
        {
          type = "shell";
          key = "{#separator}│  {#keys}󰞷 Shell:   ";
        }
        {
          type = "terminalfont";
          key = "{#separator}│  {#keys}󰛖 Font:    ";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Hardware Information
        {
          type = "custom";
          format = "{#1}│ {#}Hardware Information:";
        }
        {
          type = "cpu";
          key = "{#separator}│  {#keys}󰻠 CPU:     ";
        }
        {
          type = "gpu";
          key = "{#separator}│  {#keys}󰢮 GPU:     ";
        }
        {
          type = "memory";
          key = "{#separator}│  {#keys}󰍛 RAM:     ";
        }
        {
          type = "swap";
          key = "{#separator}│  {#keys}󰍛 Swap:    ";
        }
        {
          type = "disk";
          key = "{#separator}│  {#keys}󰋊 (/):     ";
          folders = "/";
        }
        {
          type = "disk";
          key = "{#separator}│  {#keys}󰋊 (/home): ";
          folders = "/home";
        }
        {
          type = "custom";
          format = "{#1}│";
        }
        # Uptime / Age
        {
          type = "custom";
          format = "{#1}│ {#}Uptime / Age:";
        }
        {
          type = "uptime";
          key = "{#separator}│  {#keys}󰅐 Uptime:  ";
        }
        {
          type = "command";
          key = "{#separator}│  {#keys}󰢮 OS Age:  ";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        # Footer
        {
          type = "custom";
          format = "{#1}╰─────────────────────────────────────────";
        }
      ];
    };
  };
}
