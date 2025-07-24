{
  description = "RomanK's NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-settings.url = "github:romank/vscode-settings";
  };

  outputs = {self, nixpkgs, home-manager, vscode-settings, ...}@inputs:
    let
      system = "x86_64-linux";
      version = "25.05";
      hostname = "nixos";

      user = {
        name = "romank";

        home = "/home/${user.name}";
        config = "${user.home}/.config";
        flake = "${user.config}/nixos";
      };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs user version hostname vscode-settings;
        };
        modules = [
          ./hosts/${hostname}/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit user version hostname vscode-settings;
              };
              users.${user.name} = {
                imports = [ ./home-manager/home.nix ];
              };
            };
          }
        ];
      };
    };
}