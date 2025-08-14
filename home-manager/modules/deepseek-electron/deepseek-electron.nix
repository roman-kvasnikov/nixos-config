{
  lib,
  stdenv,
  makeWrapper,
  electron,
  makeDesktopItem,
}: let
  pname = "deepseek-electron";
  version = "1.0.0";

  # Desktop entry для приложения
  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} %U";
    icon = pname;
    desktopName = "DeepSeek";
    comment = "DeepSeek in Electron";
    categories = ["Utility" "Network" "X-AI" "Chat"];
    startupWMClass = "deepseek-electron"; # Должно совпадать с WM_CLASS
  };
in
  stdenv.mkDerivation rec {
    inherit pname version;

    # Напрямую указываем файлы
    src = ./deepseek-app;

    nativeBuildInputs = [makeWrapper];

    # Никакой сборки не нужно - просто копируем файлы
    installPhase = ''
      # Создаем директории
      mkdir -p $out/lib/${pname}
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/pixmaps

      # Копируем только main.js и package.json
      cp $src/main.js $out/lib/${pname}/
      cp $src/package.json $out/lib/${pname}/

      # Копируем иконку если есть
      if [ -f $src/icon.png ]; then
        cp $src/icon.png $out/lib/${pname}/
        cp $src/icon.png $out/share/pixmaps/${pname}.png
      fi

      # Создаем wrapper который запускает electron с нашим main.js
      makeWrapper ${electron}/bin/electron $out/bin/${pname} \
        --add-flags "$out/lib/${pname}/main.js" \
        --add-flags "--enable-features=UseOzonePlatform" \
        --add-flags "--ozone-platform=wayland" \
        --set WM_CLASS "deepseek-electron" \
        --add-flags "--name=deepseek-electron" \
        --add-flags "--class=deepseek-electron"

      # Устанавливаем desktop файл
      cp ${desktopItem}/share/applications/* $out/share/applications/
    '';

    meta = with lib; {
      description = "DeepSeek wrapped in Electron";
      homepage = "https://deepseek.com";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  }
