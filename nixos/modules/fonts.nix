{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    cascadia-code
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];
}