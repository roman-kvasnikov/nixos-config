{
  pkgs,
  inputs,
  system,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
  ];

  ## TODO: СДелать это все как один оверлей, и просто применить к теме. Чтобы тут в файле sddm не было грязи, а все что относится к теме было в одном оверлее.

  nixpkgs = {
    overlays = [
      (final: prev: {
        sddm-sugar-candy = inputs.sddm-sugar-themes.packages."${system}".sddm-sugar-candy;
      })
    ];
  };

  services.displayManager.sddm = {
    enable = true;

    wayland.enable = true;

    theme = ''${
        pkgs.sddm-sugar-candy.override {
          settings = {
            Background = "${inputs.wallpapers}/banff-day.jpg";
            HourFormat = "HH:mm";
            DateFormat = "dddd, MMMM d, yyyy";
          };
        }
      }'';
  };
}
