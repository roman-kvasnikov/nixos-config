{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  name = "whatsapp-native";
  src = ~/Applications/WhatsApp-linux-x64;  # Путь к собранному приложению

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp -r . $out/share/whatsapp

    makeWrapper ${pkgs.electron}/bin/electron $out/bin/whatsapp \
      --add-flags "$out/share/whatsapp/resources/app.asar"
  '';
}