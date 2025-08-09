{
  hostname,
  system,
  version,
  config,
  user,
  inputs,
  ...
}: {
  imports = [
    ./config.nix
    ./packages.nix
    ./services.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;
  };
}
