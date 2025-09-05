{
  pkgs,
  inputs,
}: let
  image = "${inputs.wallpapers}/banff-day.jpg";
in
  pkgs.stdenv.mkDerivation {
    name = "sddm-theme";
    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
      sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
    };
    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/
      rm Background.jpg
      cp -r ${image} $out/Background.jpg
    '';
  }



  nixpkgs = {
    overlays = [
      (final: prev: {
        sddm-sugar-candy = inputs.sddm-sugar-themes.packages."${system}".sddm-sugar-candy;
      })
    ];
  };


    # SDDM theme
    sddm-sugar-themes = {
      url = "github:MOIS3Y/sddmSugarCandy4Nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    theme = ''${
        pkgs.sddm-sugar-candy.override {
          settings = {
            Background = "${inputs.wallpapers}/banff-day.jpg";
            HourFormat = "HH:mm";
            DateFormat = "dddd, MMMM d, yyyy";
          };
        }
      }'';