{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nf6 = {
      url = "github:computerdane/nf6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bop = {
      url = "github:computerdane/bop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      nf6,
      bop,
    }@inputs:
    let
      hosts = {

        bludgeonder = {
          system = "x86_64-linux";
          modules = [
            ./hardware/bludgeonder.nix
            ./hosts/bludgeonder.nix
          ];
        };

        fishtank = {
          system = "x86_64-linux";
          modules = [
            ./hardware/fishtank.nix
            ./hosts/fishtank.nix
          ];
        };

      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        name: host:
        let
          system = host.system;

          pkgs = import nixpkgs { inherit system; };
          pkgs-unstable = import nixpkgs-unstable { inherit system; };

          pkgs-1os = pkgs.callPackage ./packages/all-packages.nix { };
          pkgs-bop = bop.packages.${system};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          modules = nixpkgs.lib.flatten [
            sops-nix.nixosModules.sops
            nf6.nixosModules.${system}.server
            ./configuration.nix
            (import ./modules/all-modules.nix)
            host.modules
          ];

          specialArgs = {
            inherit
              pkgs-unstable
              pkgs-1os
              pkgs-bop
              inputs
              ;
            lib1os = pkgs-1os.lib1os;
            oneos-name = name;
          };
        }
      ) hosts;
    };
}
