{ lib, pkgs, user, ... }:

{
  # environment.etc."/brave/policies/managed/GroupPolicy.json".source = "${user.dirs.nixos-config}/home-manager/modules/brave/policies.json";

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

    # defaultSearchProviderEnabled = true;
    # defaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
    # defaultSearchProviderSuggestURL = "https://www.google.com/complete/search?output=chrome&q={searchTerms}";

    commandLineArgs = [
      "--disable-features=AutofillSavePaymentMethods"
      "--password-store"
    ];

    # extraOpts = {
    #   "BrowserSignin" = "0";
    #   "SyncDisabled" = "true";
    #   "PasswordManagerEnabled" = "false";
    #   "BuiltInDnsClientEnabled" = "false";
    #   "​DeviceMetricsReportingEnabled" = "true";
    #   "​ReportDeviceCrashReportInfo" = "true";
    #   "​SpellcheckEnabled" = "true";
    #   "​SpellcheckLanguage" = [
    #                            "en-US"
    #                            "ru-RU"
    #                          ];
    #   "​CloudPrintSubmitEnabled" = "false";
    # };
  };
}
