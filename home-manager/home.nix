{ user, version, ... }:

{
  imports = [
    ./modules
    ./home-packages.nix
  ];

  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = version;
  };
}
