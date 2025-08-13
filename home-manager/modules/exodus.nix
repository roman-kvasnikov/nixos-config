{
  config,
  pkgs,
  lib,
  ...
}: let
  exodus = pkgs.stdenv.mkDerivation rec {
    pname = "exodus";
    version = "25.28.4";

    src = pkgs.requireFile {
      name = "exodus-linux-x64-${version}.zip";
      url = "https://downloads.exodus.com/releases/exodus-linux-x64-${version}.zip";
      hash = "sha256-+g7DdDrSVmBl1wCSCoJcO2gmbWQBnJUYqjT+GuDlCYw=";
      message = ''
        Exodus needs to be downloaded manually due to license restrictions.

        1. Download exodus-linux-x64-${version}.zip from:
           ${url}

        2. Add it to the Nix store using:
           nix-store --add-fixed sha256 exodus-linux-x64-${version}.zip
      '';
    };

    nativeBuildInputs = with pkgs; [
      unzip
    ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin $out/share/applications
      cp -r . $out
      ln -s $out/Exodus $out/bin/Exodus
      ln -s $out/bin/Exodus $out/bin/exodus
      ln -s $out/exodus.desktop $out/share/applications
      substituteInPlace $out/share/applications/exodus.desktop \
        --replace 'Exec=bash -c "cd \`dirname %k\` && ./Exodus %u"' "Exec=exodus %u"
    '';

    dontPatchELF = true;
    dontBuild = true;

    preFixup = let
      libPath = lib.makeLibraryPath (with pkgs; [
        glib
        nss
        nspr
        gtk3
        pango
        atk
        cairo
        gdk-pixbuf
        xorg.libX11
        xorg.libxcb
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrender
        xorg.libxshmfence
        xorg.libXtst
        xorg.libXrandr
        xorg.libXScrnSaver
        alsa-lib
        dbus.lib
        at-spi2-atk
        at-spi2-core
        cups.lib
        libpulseaudio
        systemd
        libxkbcommon
        mesa
        # Дополнительные зависимости
        util-linux
        vivaldi-ffmpeg-codecs
      ]);
    in ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/Exodus
    '';

    meta = with lib; {
      homepage = "https://www.exodus.com/";
      description = "Top-rated cryptocurrency wallet with Trezor integration and built-in Exchange";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = with maintainers; [
        mmahut
        rople380
        Crafter
      ];
    };
  };
in {
  nixpkgs.config.allowUnfree = true;
  home.packages = [exodus];
}
