{
  pkgs,
  config,
  ...
}: {
  # nixpkgs.overlays = [
  #   (self: super: {
  #     pass = super.pass.withExtensions (exts: with exts; [pass-otp pass-import pass-update]);
  #   })
  # ];

  programs.password-store = {
    enable = true;

    package = pkgs.pass.withExtensions (exts: with exts; [pass-otp pass-import pass-update]);

    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };

  services.pass-secret-service.enable = true;

  home.packages = with pkgs; [
    qtpass # GUI for pass
  ];
}
