{
  lib,
  config,
  ...
}: {
  programs.fastfetch = lib.mkForce {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        source = "${config.xdg.configHome}/nixos/home-manager/modules/fastfetch/nixos-logo.png";
        height = 14;
        padding = {
          top = 0;
          left = 2;
          right = 2;
        };
      };

      display = {
        separator = " ";
        color = {
          "output" = "white";
          "separator" = "cyan";
        };
        key = {
          width = 16;
          type = "string";
        };
      };

      modules = [
        # Title
        {
          type = "title";
          format = "{#separator}╭──────────────── {user-name-colored}{at-symbol-colored}{host-name-colored} {#separator}────────────────";
        }
        # System Information
        {
          type = "custom";
          format = "{#separator}│ {#}System Information:";
        }
        {
          type = "os";
          key = "{#separator}│  {#blue}󰍹 OS:";
        }
        {
          type = "kernel";
          key = "{#separator}│  {#blue}󰒋 Kernel:";
        }
        {
          type = "packages";
          key = "{#separator}│  {#blue}󰏖 Packages:";
        }
        {
          type = "custom";
          format = "{#separator}│";
        }
        # Desktop Environment
        {
          type = "custom";
          format = "{#separator}│ {#}Desktop Environment:";
        }
        {
          type = "de";
          key = "{#separator}│  {#yellow}󰧨 DE:";
        }
        {
          type = "wm";
          key = "{#separator}│  {#yellow}󱂬 WM:";
        }
        {
          type = "wmtheme";
          key = "{#separator}│  {#yellow}󰉼 Theme:";
        }
        {
          type = "display";
          key = "{#separator}│  {#yellow}󰹑 Display:";
        }
        {
          type = "shell";
          key = "{#separator}│  {#yellow}󰞷 Shell:";
        }
        {
          type = "terminalfont";
          key = "{#separator}│  {#yellow}󰛖 Font:";
        }
        {
          type = "custom";
          format = "{#separator}│";
        }
        # Hardware Information
        {
          type = "custom";
          format = "{#separator}│ {#}Hardware Information:";
        }
        {
          type = "cpu";
          key = "{#separator}│  {#green}󰻠 CPU:";
        }
        {
          type = "gpu";
          key = "{#separator}│  {#green}󰢮 GPU:";
        }
        {
          type = "memory";
          key = "{#separator}│  {#green}󰍛 RAM:";
        }
        {
          type = "swap";
          key = "{#separator}│  {#green}󰍛 Swap:";
        }
        {
          type = "disk";
          key = "{#separator}│  {#green}󰋊 (/):";
          folders = "/";
        }
        {
          type = "disk";
          key = "{#separator}│  {#green}󰋊 (/home):";
          folders = "/home";
        }
        {
          type = "custom";
          format = "{#separator}│";
        }
        # Uptime / Age
        {
          type = "custom";
          format = "{#separator}│ {#}Uptime / Age:";
        }
        {
          type = "uptime";
          key = "{#separator}│  {#red}󰅐 Uptime:";
        }
        {
          type = "command";
          key = "{#separator}│  {#red}󰢮 OS Age:";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        # Footer
        {
          type = "custom";
          format = "{#separator}╰───────────────────────────────────────────────";
        }
      ];
    };
  };
}
