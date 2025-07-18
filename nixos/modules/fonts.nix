{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      font-awesome
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-emoji
    ];
  };
}
