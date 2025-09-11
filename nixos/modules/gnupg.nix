{pkgs, ...}: {
  # Fix some GUI pinentry issues
  services.dbus.packages = [pkgs.gcr];

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-all
  ];

  programs.gnupg.agent = {
    enable = true;

    pinentryPackage = pkgs.pinentry-gtk2;

    enableSSHSupport = true;
    enableExtraSocket = false;
    enableBrowserSocket = true;

    settings = {
      pinentry-program = "${pkgs.pinentry-gtk2}/bin/pinentry-gtk2";
      max-cache-ttl = 60480000;
      default-cache-ttl = 60480000;
    };
  };

  environment.etc."gnupg/gpg.conf" = {
    text = ''
      # Основные настройки
      keyid-format 0xlong
      throw-keyids
      no-emit-version
      no-comments

      # Настройки для pass
      use-agent
      pinentry-mode loopback
    '';
    mode = "0644";
  };
}
