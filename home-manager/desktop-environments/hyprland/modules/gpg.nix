{
  config,
  pkgs,
  ...
}: {
  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry-bemenu;

    extraConfig = ''
      allow-loopback-pinentry
      pinentry-program ${pkgs.pinentry-bemenu}/bin/pinentry-bemenu
    '';
  };
}
