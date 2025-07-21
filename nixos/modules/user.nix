{ pkgs, user, ... }:

{
  users = {
    defaultUserShell = pkgs.fish;

    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "networkmanager" "video" "audio" "disk" ];
    };
  };
}
