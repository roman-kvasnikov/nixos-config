{
  pkgs,
  inputs,
  wallpaper,
  ...
}: let
  sddm-background = "${inputs.wallpapers}/${wallpaper}";
  sddm-theme = ./theme.conf;

  # sddm-sugar-dark_old = pkgs.stdenv.mkDerivation {
  #   name = "sddm-sugar-dark";

  #   src = pkgs.fetchFromGitHub {
  #     owner = "MarianArlt";
  #     repo = "sddm-sugar-dark";
  #     rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
  #     sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
  #   };

  #   installPhase = ''
  #     mkdir -p $out/share/sddm/themes/sddm-sugar-dark
  #     cp -R ./* $out/share/sddm/themes/sddm-sugar-dark/
  #     cd $out/share/sddm/themes/sddm-sugar-dark/
  #     rm Background.jpg theme.conf

  #     # Копируем background.jpg
  #     cp -r ${sddm-background} $out/share/sddm/themes/sddm-sugar-dark/background.jpg
  #     cp -r ${sddm-theme} $out/share/sddm/themes/sddm-sugar-dark/theme.conf
  #   '';
  # };

  sddm-sugar-dark = pkgs.stdenv.mkDerivation {
    name = "sddm-sugar-dark";

    src = pkgs.fetchFromGitHub {
      owner = "Zhaith-Izaliel";
      repo = "sddm-sugar-candy-nix";
      rev = "c431958ed137a1a54bf6b4b2e42dc47f78296978";
      sha256 = "9c0BggSN+v44EvbFQnhn4DRl2wIfD9WbeytEG+iwD/A=";
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm-sugar-dark
      cp -R ./* $out/share/sddm/themes/sddm-sugar-dark/
      cd $out/share/sddm/themes/sddm-sugar-dark/
      rm -rf Backgrounds
      rm theme.conf

      # Копируем background.jpg
      cp -r ${sddm-background} $out/share/sddm/themes/sddm-sugar-dark/background.jpg

      # Копируем theme.conf
      cp -r ${sddm-theme} $out/share/sddm/themes/sddm-sugar-dark/theme.conf
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
