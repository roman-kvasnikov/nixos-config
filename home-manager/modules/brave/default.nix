{
  lib,
  pkgs,
  ...
}: {
  programs.chromium = lib.mkForce {
    enable = true;

    package = pkgs.brave;

    extensions = [
      "bnjjngeaknajbdcgpfkgnonkmififhfo;https://clients2.google.com/service/update2/crx" # Fake Filler
      "lfncinhjhjgebfnnblppmbmkgjgifhdf;https://clients2.google.com/service/update2/crx" # IP Address & Geolocation
      "oboonakemofpalcgghocfoadofidjkkk;https://clients2.google.com/service/update2/crx" # KeePassXC-Browser
      "nkbihfbeogaeaoehlefnkodbefgpgknn;https://clients2.google.com/service/update2/crx" # MetaMask
      "egjidjbpglichdcondbcbdnbeeppgdph;https://clients2.google.com/service/update2/crx" # Trust Wallet
    ];
  };
}
