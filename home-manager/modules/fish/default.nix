{ lib, pkgs, ... }:

{
  programs.fish = lib.mkForce {
    enable = true;

    shellAliases = {
      ls = "eza -al --color=always --group-directories-first --icons";
      la = "eza -a --color=always --group-directories-first --icons";
      ll = "eza -l --color=always --group-directories-first --icons";
      lt = "eza -aT --color=always --group-directories-first --icons";
      cat = "bat --paging=never";
    };

    interactiveShellInit = with pkgs;
      ''
        # Disable greeting
        set -g fish_greeting

        # Execute fastfetch only in interactive shells
        if status is-interactive
            fastfetch
        end
      '';
  };

  users.defaultUserShell = pkgs.fish;
}