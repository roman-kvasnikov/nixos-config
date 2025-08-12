{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;

    image = "${inputs.wallpapers}/NixOS/nix-wallpaper-binary-black.png";
    # или
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

    polarity = "dark";

    # Настройки шрифтов
    fonts = {
      serif = {
        package = pkgs.nerd-fonts.ubuntu;
        name = "Ubuntu";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.ubuntu-sans;
        name = "Ubuntu Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.ubuntu-mono;
        name = "Ubuntu Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    targets = {
      gnome.enable = true;
      vscode.enable = false;
    };
  };
}
