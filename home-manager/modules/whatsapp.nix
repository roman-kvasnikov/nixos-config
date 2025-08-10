{
  imports = [
    "${fetchTarball "https://github.com/Luis-Hebendanz/nixos-chrome-pwa/tarball/master"}/modules/chrome-pwa/home.nix"
  ];

  services.chrome-pwa.enable = true;

  programs.chrome-pwa.apps = {
    whatsapp = {
      name = "WhatsApp";
      url = "https://web.whatsapp.com";
    };
  };
}