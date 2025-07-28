{
  description = "Roman-Kvasnikov's NixOS System Configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };

    # disko = {
    #   url = "github:nix-community/disko/v1.11.0";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # My own repositories

    wallpapers = {
      url = "github:roman-kvasnikov/wallpapers";
      flake = false;
    };

    vscode-settings = {
      url = "github:roman-kvasnikov/vscode-settings";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, home-manager, ...}@inputs:
    let
      system = "x86_64-linux";

      user = {
        name = "romank";

        dirs = {
          home = "/home/${user.name}";
          config = "${user.dirs.home}/.config";
          nixos-config = "${user.dirs.config}/nixos";
        };
      };

      version = "25.05";
      hostname = "nixos";
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs user version hostname;
        };

        modules = [
          ./hosts/${hostname}/configuration.nix
        ];
      };

      homeConfigurations.${user.name} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs user version hostname;
        };

        modules = [
          ./home-manager/home.nix
        ];
      };
    };
}