{
  config,
  pkgs,
  ...
}: {
  programs.gpg = {
    enable = true;

    settings = {
      # По умолчанию все настройки ок.
    };
  };

  services.gpg-agent = {
    enable = true;

    enableSshSupport = true;

    #pinentry.package = pkgs.pinentry-gtk2;
    pinentry.package = pkgs.pinentry-bemenu;

    defaultCacheTtl = 60480000;
    maxCacheTtl = 60480000;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
