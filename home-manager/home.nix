{
  hostname,
  system,
  version,
  config,
  user,
  ...
}: {
  imports = [
    ./home-configs.nix
    ./home-packages.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;
  };
}
