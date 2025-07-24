{ lib, pkgs, ... }:

{
  programs.chromium = lib.mkForce {
    enable = true;

    package = pkgs.brave;

    extensions = [
      { id = "bnjjngeaknajbdcgpfkgnonkmififhfo"; } # Fake Filler
      { id = "lfncinhjhjgebfnnblppmbmkgjgifhdf"; } # IP Address & Geolocation
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC-Browser
      { id = "padekgcemlokbadohgkifijomclgjgif"; } # Proxy SwitchyOmega
      { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # MetaMask
      { id = "egjidjbpglichdcondbcbdnbeeppgdph"; } # Trust Wallet
    ];

    # commandLineArgs = [
    #   "--disable-features=AutofillSavePaymentMethods"
    # ];
  };
}
