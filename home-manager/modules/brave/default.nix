{
  lib,
  pkgs,
  ...
}: {
  programs.chromium = lib.mkForce {
    enable = true;

    package = pkgs.brave;

    extensions = [
      {id = "bnjjngeaknajbdcgpfkgnonkmififhfo";} # Fake Filler
      {id = "lfncinhjhjgebfnnblppmbmkgjgifhdf";} # IP Address & Geolocation
      {id = "oboonakemofpalcgghocfoadofidjkkk";} # KeePassXC-Browser
      {id = "naepdomgkenhinolocfifgehidddafch";} # Browserpass
      {id = "nkbihfbeogaeaoehlefnkodbefgpgknn";} # MetaMask
      {id = "egjidjbpglichdcondbcbdnbeeppgdph";} # Trust Wallet
    ];

    # https://chromeenterprise.google/policies/#Miscellaneous
    extraOpts = {
      "PasswordManagerEnabled" = false;
    };
  };

  programs.browserpass.enable = true;
}
