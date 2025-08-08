{
  hostname,
  system,
  version,
  config,
  user,
  ...
}: {
  imports = [
    ./config.nix
    ./packages.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;
  };
}
