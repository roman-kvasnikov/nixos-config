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
    ./services.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${config.home.username}";
    stateVersion = version;
  };

  # Установить Fish как shell по умолчанию
  programs.bash.enable = true; # Нужен как fallback
}
