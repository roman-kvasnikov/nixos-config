{ pkgs, user, ... }:

{
  programs.fish.enable = true;

  users = {
    defaultUserShell = pkgs.fish;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "networkmanager" "video" "audio" "disk" ];
    };
  };
}
