{pkgs, ...}: {
  # Fix some GUI pinentry issues
  services.dbus.packages = with pkgs; [gcr];

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-all
  ];
}
