{ pkgs, user, ... }:

{
  dconf = {
    enable = true;

    settings = {
      imports = [
        ./desktop
        ./shell
        ./keybindings.nix
        ./mutter.nix
      ];
    };
  };
}
