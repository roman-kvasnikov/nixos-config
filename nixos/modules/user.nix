{ pkgs, user, ... }:

{
  users = {
    users.${user.name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "networkmanager" "video" "audio" "disk" ];
    };
  };
}
