{ pkgs ? import <nixpkgs> {} }:

let
  appName = "whatsapp";
  url = "https://web.whatsapp.com";
  electron = pkgs.electron; # Используем стандартную версию Electron из nixpkgs
in
pkgs.stdenv.mkDerivation {
  pname = "${appName}-native";
  version = "1.0";

  nativeBuildInputs = [
    pkgs.nodePackages.nativefier
    pkgs.makeWrapper
    pkgs.autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    libappindicator
    libdbusmenu
    gtk3
    cairo
  ];

  buildPhase = ''
    nativefier "${url}" \
      --name "${appName}" \
      --platform linux \
      --arch x64 \
      --single-instance \
      --tray
  '';

  installPhase = ''
    mkdir -p $out/{bin,share/applications,share/icons/hicolor/256x256/apps}
    cp -r ${appName}-linux-x64/* $out/share/whatsapp
    
    makeWrapper ${electron}/bin/electron $out/bin/whatsapp \
      --add-flags "$out/share/whatsapp/resources/app.asar" \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
        pkgs.libappindicator
        pkgs.libdbusmenu
      ]}
    
    cp $out/share/whatsapp/resources/app/icon.png $out/share/icons/hicolor/256x256/apps/whatsapp.png
    
    cat > $out/share/applications/whatsapp.desktop <<EOF
    [Desktop Entry]
    Name=WhatsApp
    Exec=$out/bin/whatsapp
    Icon=whatsapp
    Type=Application
    Categories=Network;InstantMessaging;
    EOF
  '';

  dontAutoPatchelf = false;
}