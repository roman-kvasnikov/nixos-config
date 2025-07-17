{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    btop
    curl
    htop
    git
    unzip
    wget
    zip
  ];
}
