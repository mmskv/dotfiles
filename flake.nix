{
  description = "mmskv's nixos infra";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ucodenix.url = "github:e-tho/ucodenix";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    impermanence,
    home-manager,
    ucodenix,
    nix-index-database,
    agenix,
  }: let
    sec = import ./secrets.nix;

    mkSystem = {
      hostConfig,
      users,
      agenixSecrets,
    }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit sec;};
        modules = [
          ./common
          hostConfig
          impermanence.nixosModules.impermanence
          ucodenix.nixosModules.default

          nix-index-database.nixosModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              inherit users;
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit sec;
                pkgs-unstable = import nixpkgs-unstable {
                  system = "x86_64-linux";
                };
              };
            };
          }

          agenix.nixosModules.default
          agenixSecrets
        ];
      };
  in {
    nixosConfigurations = {
      Wintermute = mkSystem {
        hostConfig = ./hosts/wintermute;
        users.suck = import ./home/desktop.nix;
        agenixSecrets = {
          age.secrets."zrepl/ca.crt".file = ./secrets/zrepl/ca.crt.age;
          age.secrets."zrepl/Wintermute.crt".file = ./secrets/zrepl/Wintermute.crt.age;
          age.secrets."zrepl/Wintermute.key".file = ./secrets/zrepl/Wintermute.key.age;
        };
      };
      Hosaka = mkSystem {
        hostConfig = ./hosts/hosaka;
        users.root = import ./home/minimal.nix;
        agenixSecrets = {
          age.secrets."zrepl/ca.crt".file = ./secrets/zrepl/ca.crt.age;
        };
      };
    };
  };
}
