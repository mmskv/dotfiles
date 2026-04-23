{
  description = "mmskv's nixos infra";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ucodenix.url = "github:e-tho/ucodenix/98c0b8ec151ee6495711d2dd902112b4f2a30ceb";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    # hy3 dictates the Hyprland version — everything else follows its pin
    hy3.url = "github:outfoxxed/hy3";
    hyprland.follows = "hy3/hyprland";

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hy3/hyprland";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    impermanence,
    home-manager,
    ucodenix,
    nix-index-database,
    agenix,
    hyprland,
    hy3,
    hyprsplit,
    nixgl,
    ...
  }: let
    system = "x86_64-linux";
    hyprlandPackages = {
      hyprland-pkg = hyprland.packages.${system}.hyprland;
      hyprland-xdph = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
      hy3-pkg = hy3.packages.${system}.hy3;
      hyprsplit-pkg = hyprsplit.packages.${system}.hyprsplit;
    };
    sec = import ./secrets.nix;
    specialArgs = {
      inherit sec hyprlandPackages;

      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };
    extraSpecialArgs = specialArgs;
  in {
    nixosConfigurations = {
      Wintermute = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;

        modules = [
          ./common
          ./hosts/wintermute

          impermanence.nixosModules.impermanence
          ucodenix.nixosModules.default

          nix-index-database.nixosModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.suck = ./home/desktop.nix;

              useGlobalPkgs = true;
              useUserPackages = true;

              inherit extraSpecialArgs;
            };
          }

          agenix.nixosModules.default
          {
            age.secrets = {
              "zrepl/ca.crt".file = ./secrets/zrepl/ca.crt.age;
              "zrepl/Wintermute.crt".file = ./secrets/zrepl/Wintermute.crt.age;
              "zrepl/Wintermute.key".file = ./secrets/zrepl/Wintermute.key.age;
            };
          }
        ];
      };

      Hosaka = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit specialArgs;

        modules = [
          ./common
          ./hosts/hosaka

          impermanence.nixosModules.impermanence
          ucodenix.nixosModules.default

          nix-index-database.nixosModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
          }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.root = ./home/minimal.nix;

              useGlobalPkgs = true;
              useUserPackages = true;

              inherit extraSpecialArgs;
            };
          }

          agenix.nixosModules.default
          {
            age.secrets = {
              "zrepl/ca.crt".file = ./secrets/zrepl/ca.crt.age;
              "zrepl/Hosaka.crt".file = ./secrets/zrepl/Hosaka.crt.age;
              "zrepl/Hosaka.key".file = ./secrets/zrepl/Hosaka.key.age;
            };
          }
        ];
      };
    };

    homeConfigurations."suck@thinkpad" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [nixgl.overlay];
      };
      extraSpecialArgs = {
        inherit sec nixgl hyprlandPackages;

        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [nixgl.overlay];
        };
      };
      modules = [
        nix-index-database.homeModules.nix-index
        {programs.nix-index-database.comma.enable = true;}
        ./home/thinkpad.nix
      ];
    };
  };
}
