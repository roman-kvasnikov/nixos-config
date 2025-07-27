{ pkgs, ... }:

{
  stylix = {
    enable = true;

    # Выбор темы (можно указать изображение или цвет)
    # image = ./path/to/your/wallpaper.jpg;
    # или
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    # Настройки шрифтов
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
    };

    # Настройки для конкретных приложений
    targets = {
      gnome.enable = true;
      # Другие цели...
    };
  };
}