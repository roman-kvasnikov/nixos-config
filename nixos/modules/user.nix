{ pkgs, user, ... }:

{
  users = {
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "networkmanager" "video" "audio" "disk" ];
    };
  };
}
