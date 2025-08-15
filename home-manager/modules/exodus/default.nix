{pkgs, ...}: {
  home.packages = with pkgs; [
    exodus
  ];

  xdg = {
    dataFile."icons/exodus.png".source = ./icon.png;

    desktopEntries.exodus = {
      name = "Exodus";
      comment = "Crypto wallet";
      exec = "exodus";
      icon = "exodus";
      categories = ["X-Crypto Wallet"];
    };
  };
}
