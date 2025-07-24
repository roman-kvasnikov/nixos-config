{ pkgs, ... }:

{
  imports = [
    ./desktop
    ./shell
    ./keybindings.nix
    ./mutter.nix
  ];

  dconf.enable = true;
}
