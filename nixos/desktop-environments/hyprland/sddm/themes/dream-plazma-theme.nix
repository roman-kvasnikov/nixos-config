{
  pkgs,
  inputs,
}: let
  image = "${inputs.wallpapers}/banff-day.jpg";
in
  pkgs.stdenv.mkDerivation {
    name = "slot-plazma-theme";

    src = pkgs.fetchFromGitHub {
      owner = "L4ki";
      repo = "Slot-Plasma-Themes";
      rev = "ab7f2bedbc21fd89c68d5817fd73bf5dbbdb3588";
      sha256 = "pH21sHMZ/LFmLALP2GW/hXYrEiIicvbWKMdtRXJaRjc=";
    };

    sourceRoot = "source/Slot SDDM Themes/Slot-SDDM-6";

    installPhase = ''
      echo "=== Theme files ==="
      ls -la

      echo "=== Checking for required files ==="
      for file in Main.qml metadata.desktop theme.conf; do
        if [ -f "$file" ]; then
          echo "✓ Found: $file"
        else
          echo "✗ Missing: $file"
        fi
      done

      mkdir -p $out
      cp -R ./* $out/

      # Попробуйте заменить фон, если файл существует
      for bg in background.jpg Background.jpg wallpaper.jpg preview.jpg; do
        if [ -f "$out/$bg" ]; then
          echo "Replacing $bg with custom image"
          rm -f "$out/$bg"
          cp ${image} "$out/$bg"
        fi
      done

      # Проверяем theme.conf на предмет пути к фону
      if [ -f "$out/theme.conf" ]; then
        echo "=== theme.conf content ==="
        cat "$out/theme.conf"
      fi
    '';
  }
