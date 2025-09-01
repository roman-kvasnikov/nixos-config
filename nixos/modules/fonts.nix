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

    enableDefaultPackages = true;

    packages = with pkgs; [
      font-awesome
      nerd-fonts.fira-code
      fira-sans
      nerd-fonts.fira-mono
      fira-code-symbols
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      noto-fonts-emoji
      noto-fonts
    ];
  };
}
