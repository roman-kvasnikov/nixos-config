{
  pkgs,
  inputs,
  ...
}: let
  sddm-background = "${inputs.wallpapers}/banff-day.jpg";
  sddm-theme = "./theme.conf";

  sddm-sugar-dark = pkgs.stdenv.mkDerivation {
    name = "sddm-sugar-dark";

    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
      sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm-sugar-dark
      cp -R ./* $out/share/sddm/themes/sddm-sugar-dark/
      cd $out/share/sddm/themes/sddm-sugar-dark/
      rm Background.jpg theme.conf

      # Копируем background.jpg
      cp -r ${sddm-background} $out/share/sddm/themes/sddm-sugar-dark/background.jpg
      cp -r ${sddm-theme} $out/share/sddm/themes/sddm-sugar-dark/theme.conf

      # Создаем theme.conf с нашими настройками
      # cat > $out/share/sddm/themes/sddm-sugar-dark/theme.conf << EOF
      # [General]
      # Background="background.jpg"
      # HourFormat="HH:mm"
      # DateFormat="dddd, MMMM d, yyyy"
      # EOF
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects
  ];
}
