{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  stylix = {
    autoEnable = true;
    enable = true;

    image = "${inputs.wallpapers}/banff-day.jpg";
    imageScalingMode = "fill";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";

    fonts = {
      # С засечками
      serif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      # Без засечек
      sansSerif = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      # Моноширинный
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      # Эмоджи
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        desktop = 10;
        popups = 10;
        applications = 12;
        terminal = 12;
      };
    };

    opacity = {
      desktop = 1.0;
      popups = 0.9;
      applications = 1.0;
      terminal = 0.95;
    };

    targets = {
      gtk.enable = true;
      qt.enable = true;
      kitty.enable = false;
      vscode.enable = false;
    };
  };
}
