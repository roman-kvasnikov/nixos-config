{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    enable = true;

    # Wallpaper и цветовая схема
    image = "${inputs.wallpapers}/NixOS/wp12329533-nixos-wallpapers.png";
    imageScalingMode = "fill";
    polarity = "dark";

    # Шрифты для GNOME
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

    # Прозрачность элементов
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 0.9;
      terminal = 0.95;
    };

    targets = {
      gnome.enable = true;
      kitty.enable = false; # Отдельно настроим в модуле kitty
      vscode.enable = false; # Отдельно настроим в модуле vscode
    };
  };
}
