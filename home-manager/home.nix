{ user, version, ... }:

{
  imports = [
    ./modules
    ./home-packages.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = version;
  };
}
