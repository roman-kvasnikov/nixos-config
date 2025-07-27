{ pkgs, inputs, ... }:

{
  stylix = {
    enable = true;

    image = "${inputs.wallpapers}/jost-van-dyke-british-virgin-islands-beach-boats-clouds-3840x2160-4074.jpg";
    # или
    base16Scheme = "${pkgs.base16-schemes}/share/themes/measured-dark.yaml";

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

    # Настройки для конкретных приложений
    targets = {
      gnome.enable = true;
      # code-cursor.enable = false;
    };
  };
}