{
  description = "RomanK's NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, home-manager, ...}@inputs:
    let
      system = "x86_64-linux";
      version = "25.05";
      user = "romank";
      hostname = "nixos";

      # user = {
      #   fullname = "Santiago Fuentes";
      #   name = "sfuentes";
      #   mail = "dev@sfuentes.cl";
      #   language = "us";
      #   system = "x86_64-linux";

      #   home = "/home/${user.name}";
      #   flake = "${user.home}/NixOS";
      #   documents = "${user.home}/Documents";
      #   downloads = "${user.home}/Downloads";
      #   media = "${user.home}/Media";
      #   sync = "${user.home}/Sync";
      #   wallpapers = "${user.media}/Wallpapers";
      #   recordings = "${user.media}/Recordings";
      #   screenshots = "${user.media}/Screenshots";
      #   cache = "${user.home}/.cache";
      #   config = "${user.home}/.config";
      #   data = "${user.home}/.local/share";
      #   state = "${user.home}/.local/state";
      # };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs user version hostname;
        };
        modules = [
          ./hosts/${hostname}/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit user version hostname;
              };
              users.${user} = {
                imports = [ ./home-manager/home.nix ];
              };
            };
          }
        ];
      };
    };
}