{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    bottom
  ];

  xdg.configFile."bottom/config.toml".text = ''
    [processes]
    command = "kitty"
  '';
}
