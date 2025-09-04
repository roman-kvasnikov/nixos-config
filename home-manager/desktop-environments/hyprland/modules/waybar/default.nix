{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    wttrbar
    (callPackage ./packages/waybar-restart/package.nix {inherit pkgs;}) # Waybar Restart
  ];

  programs.waybar = {
    enable = true;

    settings = import ./config.nix {inherit config lib pkgs;};
    style =
      builtins.replaceStrings
      [
        "@configDirectory@"
      ]
      [
        "${config.xdg.configHome}"
      ]
      (builtins.readFile ./style.css);
  };

  xdg.configFile = {
    "waybar/icons/btc-rate/btc-logo.svg".source = ./icons/btc-rate/btc-logo.svg;
    "waybar/icons/btc-rate/btc-logo-green.svg".source = ./icons/btc-rate/btc-logo-green.svg;
    "waybar/icons/btc-rate/btc-logo-red.svg".source = ./icons/btc-rate/btc-logo-red.svg;
    "waybar/icons/eth-rate/eth-logo.svg".source = ./icons/eth-rate/eth-logo.svg;
    "waybar/icons/eth-rate/eth-logo-green.svg".source = ./icons/eth-rate/eth-logo-green.svg;
    "waybar/icons/eth-rate/eth-logo-red.svg".source = ./icons/eth-rate/eth-logo-red.svg;
    "waybar/icons/gala-rate/gala-logo.svg".source = ./icons/gala-rate/gala-logo.svg;
    "waybar/icons/gala-rate/gala-logo-green.svg".source = ./icons/gala-rate/gala-logo-green.svg;
    "waybar/icons/gala-rate/gala-logo-red.svg".source = ./icons/gala-rate/gala-logo-red.svg;

    "waybar/scripts/crypto-rates.sh" = {
      source = ./scripts/crypto-rates.sh;
      executable = true;
    };

    "waybar/scripts/weather.sh" = {
      source = ./scripts/weather.sh;
      executable = true;
    };
  };
}
