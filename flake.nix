{
  description = "Roman-Kvasnikov's NixOS System Configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };


    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
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

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    shared = import ./shared.nix;
    inherit (shared) hosts user;

    makeSystem = host:
      nixpkgs.lib.nixosSystem {
        inherit (host) system;

        specialArgs = {
          inherit inputs user;
          inherit (host) hostname system version;
        };

        modules = [
          ./hosts/${host.hostname}/configuration.nix
        ];
      };

    makeHome = host:
      home-manager.lib.homeManagerConfiguration {
        pkgs =
          nixpkgs.legacyPackages.${host.system}
          // {
            config.allowUnfree = true;
          };

        extraSpecialArgs = {
          inherit inputs user;
          inherit (host) hostname system version;
        };

        modules = [
          ./home-manager/home.nix
        ];
      };
  in {
    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        name = host.hostname;
        value = makeSystem host;
      })
      hosts
    );

    homeConfigurations = builtins.listToAttrs (
      map (host: {
        name = "${user.name}@${host.hostname}";
        value = makeHome host;
      })
      hosts
    );
  };
}
