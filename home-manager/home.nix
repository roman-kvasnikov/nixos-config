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

    keyboard = {
      layout = "us,ru";
      options = ["grp:ctrl_shift_toggle"];
    };

    stateVersion = version;
  };
}
