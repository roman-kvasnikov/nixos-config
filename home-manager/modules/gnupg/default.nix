{pkgs, ...}: {
  home.packages = with pkgs; [
    gnupg
    pinentry-all
  ];

  programs.gnupg.agent = {
    enable = true;

    pinentryPackage = pkgs.pinentry-gtk2;

    enableSSHSupport = true;
  };

  home.file = {
    ".gnupg/gpg.conf".source = ./gpg.conf;
    ".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
  };
}
