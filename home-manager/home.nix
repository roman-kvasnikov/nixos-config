{
  config,
  user,
  version,
  ...
}: {
  imports = [
    ./config
    ./packages.nix
    ./services.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;

    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "micro";
      XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";

      FONT_FAMILY = "FiraCode Nerd Font";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];
  };
}
