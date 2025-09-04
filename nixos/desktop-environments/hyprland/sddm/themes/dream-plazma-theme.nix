{
  pkgs,
  inputs,
}: let
  image = "${inputs.wallpapers}/banff-day.jpg";
in
  pkgs.stdenv.mkDerivation {
    name = "sddm-theme";

    src = pkgs.fetchFromGitHub {
      owner = "L4ki";
      repo = "Dream-Plasma-Themes";
      rev = "4b281c69ca0425a9f993506736c7eb47b73a824f";
      sha256 = "";
    };

    sourceRoot = "Dream SDDM Login Themes/Dream-Light--SDDM-6";

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/
    '';
  }
