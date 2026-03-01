{pkgs, ...}: {
  # 🔧 Фикс для сломанного noto-fonts-subset в unstable 26.05. Потом можно удалить.
  nixpkgs.overlays = [
    (final: prev: {
      noto-fonts-subset = prev.noto-fonts;
    })
  ];

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
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
