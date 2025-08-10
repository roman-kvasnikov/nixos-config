{lib, ...}: {
  programs.obsidian = lib.mkForce {
    enable = true;
  };
}
