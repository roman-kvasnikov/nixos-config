{
  pkgs,
  inputs,
}: let
  image = "${inputs.wallpapers}/banff-day.jpg";
  theme = ./theme.conf;
in
  pkgs.stdenv.mkDerivation {
    name = "sddm-sugar-dark";

    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "33a179de097f41bb2b3de0fba46f0776801826c3";
      sha256 = "flOspjpYezPvGZ6b4R/Mr18N7N3JdytCSwwu6mf4owQ=";
    };

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/
      rm Background.jpg
      cp -r ${image} $out/background.jpg
      cp -r ${theme} $out/theme.conf
    '';
  }
