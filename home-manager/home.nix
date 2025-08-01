{
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ./modules
    ./home-packages.nix
    ./home-configs.nix
  ];

  home = {
    username = user.name;
    homeDirectory = user.dirs.home;
    stateVersion = version;
  };
}
