{
  config,
  pkgs,
  ...
}: {
  # Устанавливаем наше расширение в локальную папку расширений
  home.file = {
    ".local/share/gnome-shell/extensions/xray-toggle@romank-nixos/extension.js" = {
      source = ./extension.js;
    };
    
    ".local/share/gnome-shell/extensions/xray-toggle@romank-nixos/metadata.json" = {
      source = ./metadata.json;
    };

    ".local/share/gnome-shell/extensions/xray-toggle@romank-nixos/stylesheet.css" = {
      source = ./stylesheet.css;
    };
  };

  # Включаем расширение в dconf
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "xray-toggle@romank-nixos"
      ];
    };
  };
}