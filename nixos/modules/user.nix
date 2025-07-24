{ pkgs, user, ... }:

{
  users = {
    defaultUserShell = pkgs.fish;

    users.${user.name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "networkmanager" "video" "audio" "disk" ];
    };
  };
}
