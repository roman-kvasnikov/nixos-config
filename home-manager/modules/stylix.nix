{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;

    image = "${inputs.wallpapers}/NixOS/nix-wallpaper-binary-black.png";
    imageScalingMode = "fill"; # "fill", "fit", "stretch", "center", "tile"
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

    opacity = {
      applications = 1.0; # Непрозрачность приложений
      desktop = 1.0; # Непрозрачность элементов рабочего стола
      popups = 0.9; # Прозрачность всплывающих окон
      terminal = 0.95; # Прозрачность терминала
    };

    targets = {
      gnome.enable = true;
      kitty.enable = false;
      vscode.enable = false;
    };
  };
}
