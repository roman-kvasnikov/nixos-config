{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-all
  ];

  programs.gnupg.agent = {
    enable = true;

    pinentryPackage = pkgs.pinentry-curses;

    enableSSHSupport = true;
  };
}
