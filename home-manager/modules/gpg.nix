{
  config,
  pkgs,
  ...
}: {
  programs.gpg = {
    enable = true;

    settings = {
      # default-key = "YOUR_KEY_ID";
      # trusted-key = "YOUR_KEY_ID";
      no-greeting = true;
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;

    enableSshSupport = true;
    enableExtraSocket = false;
    enableBrowserSocket = true;

    defaultCacheTtl = 60480000;
    maxCacheTtl = 60480000;
    pinentryPackage = pkgs.pinentry-gtk2;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  home.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
}
