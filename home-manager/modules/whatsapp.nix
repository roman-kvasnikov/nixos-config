{
  imports = [
    "${fetchTarball "https://github.com/Luis-Hebendanz/nixos-chrome-pwa/tarball/master"}/modules/chrome-pwa/home.nix"
  ];

  services.chrome-pwa.enable = true;

  # Создание .desktop файла для Discord PWA
  home.file.".local/share/applications/whatsapp-pwa.desktop".text = ''
    [Desktop Entry]
    Name=WhatsApp
    Comment=WhatsApp - Голосовой и текстовый чат для геймеров
    Exec=brave --app=https://web.whatsapp.com
    Icon=whatsapp
    Type=Application
    Categories=Network;InstantMessaging;
    Keywords=whatsapp;chat;voice;gaming;
    StartupWMClass=whatsapp.com
    NoDisplay=false
  '';
}