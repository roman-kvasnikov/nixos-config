{
  pkgs,
  user,
  ...
}: {
  users = {
    users.${user.name} = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = ["wheel" "input" "networkmanager" "video" "audio" "disk"];
    };
  };
}
