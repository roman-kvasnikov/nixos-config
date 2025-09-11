{
  config,
  pkgs,
  ...
}: {
  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry-gtk2;

    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry-gtk-2
    '';
  };
}
