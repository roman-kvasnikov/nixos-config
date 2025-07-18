{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      cascadia-code
      dina-font
      fira-code
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      proggyfonts
      ubuntu_font_family
      liberation_ttf
    ];
  };
}
