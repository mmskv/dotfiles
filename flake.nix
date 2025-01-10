{
  description = "mmskv's nixos infra";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ucodenix.url = "github:e-tho/ucodenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ucodenix,
    }:
    let
      sec = import ./secrets.nix;

      mkSystem =
        hostConfig: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit sec; };
          modules = [
            hostConfig
            ucodenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                users.suck = import ./home;
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit sec;
                  pkgs-unstable = import nixpkgs-unstable {
                    inherit system;
                  };
                };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        Wintermute = mkSystem ./hosts/wintermute "x86_64-linux";
      };
    };
}
