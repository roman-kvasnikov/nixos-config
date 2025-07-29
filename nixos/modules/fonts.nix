{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      # builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts)
      noto-fonts
      noto-fonts-emoji
    ];
  };
}
