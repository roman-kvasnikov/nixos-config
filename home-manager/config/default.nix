{
  config,
  user,
  version,
  ...
}: {
  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;

    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "nano";
      XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    file = {
      "${config.xdg.userDirs.templates}/NewDocument.txt".text = "";
    };
  };

  imports = [
    ./gtk.nix
    ./xdg.nix
  ];
}
