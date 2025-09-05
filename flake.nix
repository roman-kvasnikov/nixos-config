{
  description = "Roman-Kvasnikov's NixOS System Configuration";

  inputs = {
    # === ОСНОВНЫЕ INPUTS ===

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # url = "github:nix-community/home-manager/release-25.05";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # === СИСТЕМНЫЕ РАСШИРЕНИЯ ===

    # Grub theme
    nixos-grub-themes = {
      url = "github:jeslie0/nixos-grub-themes";
    };

    # SDDM theme
    # sddm-sugar-themes = {
    #   url = "github:MOIS3Y/sddmSugarCandy4Nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Stylix
    stylix = {
      # url = "github:nix-community/stylix/release-25.05";
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # === DEVELOPMENT TOOLS ===

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # === ПЕРСОНАЛЬНЫЕ РЕПОЗИТОРИИ ===

    obsidianVault = {
      url = "git@github.com:roman-kvasnikov/obsidian-vault.git";
      flake = false;
    };

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
          inherit (host) hostname desktop system version;
        };

        modules = [
          ./hosts/${host.hostname}/configuration.nix
          ./nixos/desktop-environments/${host.desktop}
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
          inherit (host) hostname desktop system version;
        };

        modules = [
          ./home-manager/home.nix
          ./home-manager/desktop-environments/${host.desktop}
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
