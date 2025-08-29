let
  pkgs = import <nixpkgs> {};
  tableplus = pkgs.stdenv.mkDerivation {
    name = "TablePlus";
    src = pkgs.fetchurl {
      url = "https://deb.tableplus.com/debian/pool/main/t/tableplus/tableplus_0.1.264_amd64.deb";
      sha256 = "01bfrv91hrigq5rni9vignlnhfr33zwhya5nivqi545cjmqfrv2w";
    };
    sourceRoot = "opt/tableplus";

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/icons/hicolor/256x256/apps"

      cp -R "tableplus" "$out/bin/tableplus"
      cp -R "resource/" "$out/share"

      # Создаем desktop файл
      cat > "$out/share/applications/tableplus.desktop" << EOF
      [Desktop Entry]
      Name=TablePlus
      Comment=Database management tool
      Exec=$out/bin/tableplus
      Icon=tableplus
      Terminal=false
      Type=Application
      Categories=Development;Database;
      EOF

      # Копируем иконку
      cp "resource/icon.png" "$out/share/icons/hicolor/256x256/apps/tableplus.png"

      chmod +x "$out/bin/tableplus"
      runHook postInstall
    '';

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      dpkg
      makeWrapper
      wrapGAppsHook
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      libgee
      json-glib
      openldap
      gtksourceview4
      gnome.libsecret
      gnome.gtksourceview
    ];
  };
in
  tableplus
