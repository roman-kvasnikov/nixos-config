{lib, ...}: {
  programs.obsidian = lib.mkForce {
    enable = true;

    vaults."Garbage/Notes".enable = true;
  };
}
