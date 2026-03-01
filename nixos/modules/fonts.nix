{pkgs, ...}: {
  fonts = {
    fontDir.enable = true;

    fontconfig = {
      enable = true;

      antialias = true;

      hinting = {
        enable = true;
        style = "slight"; # Современный hinting
      };

      subpixel = {
        rgba = "rgb"; # Для LCD мониторов
        lcdfilter = "default";
      };
    };

    enableDefaultPackages = false; # Изменил на false, потому что на новой 26.05 ругалась на noto-fonts-subset

    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
