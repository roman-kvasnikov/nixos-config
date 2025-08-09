{pkgs, ...}:
let
  whatsappWeb = pkgs.writeShellScriptBin "whatsapp-web" ''
    # Используем Brave в app режиме для лучшей интеграции
    exec ${pkgs.brave}/bin/brave \
      --app=https://web.whatsapp.com/ \
      --class=whatsapp-web \
      --name=whatsapp-web \
      --user-data-dir="$HOME/.config/whatsapp-web" \
      --enable-features=VaapiVideoDecoder \
      --use-gl=desktop \
      --enable-gpu-rasterization \
      --enable-zero-copy \
      --disable-features=UseChromeOSDirectVideoDecoder \
      "$@"
  '';

  whatsappDesktop = pkgs.makeDesktopItem {
    name = "whatsapp-web";
    desktopName = "WhatsApp";
    exec = "${whatsappWeb}/bin/whatsapp-web";
    icon = "whatsapp";
    categories = ["Network" "InstantMessaging"];
    comment = "WhatsApp Web Application";
    startupNotify = true;
    startupWMClass = "whatsapp-web";
    mimeTypes = ["x-scheme-handler/whatsapp"];
  };

in {
  home.packages = [
    whatsappWeb
    whatsappDesktop
  ];
}