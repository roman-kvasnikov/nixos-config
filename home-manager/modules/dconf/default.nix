{pkgs, ...}: {
  imports = [
    ./desktop
    ./shell
    ./keybindings.nix
    ./mutter.nix
    ./proxy.nix
  ];

  dconf.enable = true;
}
