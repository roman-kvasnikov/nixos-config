{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      cascadia-code
      dina-font
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      noto-fonts
      noto-fonts-emoji
      proggyfonts
      ubuntu_font_family
      liberation_ttf
    ];
  };
}
