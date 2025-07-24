{ lib, pkgs, ... }:

{
  programs.chromium = lib.mkForce {
    enable = true;

    package = pkgs.brave;

    profiles = {
      "Home" = {
        id = 0;
        isDefault = true;
      };
      "Work" = {
        id = 1;
        isDefault = false;
      };
    };

    extensions = [
      { id = "bnjjngeaknajbdcgpfkgnonkmififhfo"; } # Fake Filler
      { id = "lfncinhjhjgebfnnblppmbmkgjgifhdf"; } # IP Address & Geolocation
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # KeePassXC-Browser
      { id = "padekgcemlokbadohgkifijomclgjgif"; } # Proxy SwitchyOmega
      { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # MetaMask
      { id = "egjidjbpglichdcondbcbdnbeeppgdph"; } # Trust Wallet
    ];

    # defaultSearchProviderEnabled = true;
    # defaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
    # defaultSearchProviderSuggestURL = "https://www.google.com/complete/search?output=chrome&q={searchTerms}";

    # commandLineArgs = [
    #   "--disable-features=AutofillSavePaymentMethods"
    # ];
  };
}
