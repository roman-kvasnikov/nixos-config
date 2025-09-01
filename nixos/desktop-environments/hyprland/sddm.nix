{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.sddm-stray-nixos.packages.${pkgs.system}.default
  ];

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
    ];
    wayland.enable = true;
    theme = "sddm-stray-nixos";
  };
}
