{pkgs, ...}: let
  openldap_2_4 =
    (import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/20c060c763107b735f4635faa7722de02f461006.tar.gz";
        sha256 = "sha256:0m98bkkq94fknb0fjpxsr1kbm69xqq4krxxn4q5kkzxhdjaf2hqv";
      }) {
        inherit (pkgs.stdenv.hostPlatform) system;
      })
    .openldap;
in {
  home.packages = [
    (pkgs.stdenv.mkDerivation rec {
      name = "tableplus";
      version = "0.1.258";

      src =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux"
        then
          pkgs.fetchurl {
            url = "https://deb.tableplus.com/debian/pool/main/t/tableplus/tableplus_0.1.264_amd64.deb";
            sha256 = "uH4Tl7rttTWmw+12IFMOGHIPb1rUxrr8hWPulgR8mpY=";
          }
        else if pkgs.stdenv.hostPlatform.system == "aarch64-linux"
        then
          pkgs.fetchurl {
            url = "https://deb.tableplus.com/debian/22-arm/pool/main/t/tableplus/tableplus_${version}_arm64.deb";
            sha256 = "sha256-placeholder-aarch64";
          }
        else throw "Unsupported platform: ${pkgs.stdenv.hostPlatform.system}";

      nativeBuildInputs = [
        pkgs.dpkg
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
        pkgs.wrapGAppsHook
      ];

      buildInputs = [
        pkgs.glib
        pkgs.gtk3
        pkgs.libgee
        pkgs.json-glib
        pkgs.gtksourceview3
        pkgs.libkrb5
        pkgs.libsecret
        openldap_2_4
      ];

      unpackPhase = ''
        runHook preUnpack
        dpkg-deb -x ${src} .
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/bin"
        mkdir -p "$out/share/applications"

        cp "opt/tableplus/tableplus" "$out/bin/"
        cp "opt/tableplus/tableplus.desktop" "$out/share/applications/"
        cp -r "opt/tableplus/resource" "$out/"

        substituteInPlace "$out/share/applications/tableplus.desktop" \
          --replace "/usr/local/bin/tableplus" "$out/bin/tableplus" \
          --replace "/opt/tableplus/resource/image/logo.png" "$out/resource/image/logo.png"

        chmod -R g-w "$out"

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "TablePlus - Native Database GUI for Linux";
        homepage = "https://tableplus.com/";
        license = licenses.unfree;
        platforms = platforms.linux;
        maintainers = with maintainers; [];
      };
    })
  ];
}
