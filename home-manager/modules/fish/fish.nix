{ lib, user, ... }:

{
  programs.fish = lib.mkForce {
    enable = true;
    shellInit = builtins.readFile "/home/${user}/.config/nixos/home-manager/modules/fish/config.fish";
  };
}