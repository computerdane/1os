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
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      nf6,
      utils,
    }:
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

          pkgs-nf6 = nf6.packages.${system};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          modules = nixpkgs.lib.flatten [
            sops-nix.nixosModules.sops
            pkgs-nf6.nixosModules
            ./configuration.nix
            (import ./modules/all-modules.nix)
            host.modules
          ];

          specialArgs = {
            inherit pkgs-unstable pkgs-1os pkgs-nf6;
            lib1os = pkgs-1os.lib1os;
            oneos-name = name;
          };
        }
      ) hosts;
    }
    // (utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = pkgs.callPackage ./packages/all-packages.nix { };
      }
    ));
}
