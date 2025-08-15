{
  config,
  pkgs,
  ...
}: {
  # Устанавливаем наше расширение в локальную папку расширений
  xdg.datafile = {
    "gnome-shell/extensions/xray-toggle@romank-nixos/extension.js" = {
      source = ./extension.js;
    };

    "gnome-shell/extensions/xray-toggle@romank-nixos/metadata.json" = {
      source = ./metadata.json;
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
