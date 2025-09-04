{
  pkgs,
  inputs,
}: let
  image = "${inputs.wallpapers}/banff-day.jpg";
in
  pkgs.stdenv.mkDerivation {
    name = "sddm-sugar-candy-nix";

    src = pkgs.fetchFromGitHub {
      owner = "Zhaith-Izaliel";
      repo = "sddm-sugar-candy-nix";
      rev = "0805d18392017fe205e11ab51da3fa90fd1dc63a";
      sha256 = "5ytzzq9mqB2yI4GD85+LEKaIlzcn6gKaW6purFwmsLI=";
    };

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
    '';
  }
