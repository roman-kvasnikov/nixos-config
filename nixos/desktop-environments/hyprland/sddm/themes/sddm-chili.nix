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
      repo = "sddm-chili";
      rev = "980f9d83337c7761883245b1d419d2a5becd2850";
      sha256 = "E6DAXEclgW2cWs7jbDgf4TEGwLEE9xC7rxPtN0Jb/8A=";
    };

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/
      rm assets/background.jpg
      cp -r ${image} $out/assets/background.jpg
    '';
  }
