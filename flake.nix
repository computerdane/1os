{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      utils,
      treefmt-nix,
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

        eefan = {
          system = "x86_64-linux";
          modules = [
            ./hardware/eefan.nix
            ./hosts/eefan.nix
          ];
        };

        fishtank = {
          system = "x86_64-linux";
          modules = [
            ./hardware/fishtank.nix
            ./hosts/fishtank.nix
          ];
        };

        limbo = {
          system = "x86_64-linux";
          modules = [
            ./hardware/limbo.nix
            ./hosts/limbo.nix
          ];
        };

      };
    in
    (utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        packages = import ./packages/all-packages.nix { callPackage = pkgs.callPackage; };
        lib1os = pkgs.callPackage ./lib/lib.nix { };
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;
      }
    ))
    // {
      nixosConfigurations = builtins.mapAttrs (
        name: host:
        let
          system = host.system;
          pkgs-unstable = import nixpkgs-unstable { inherit system; };
          pkgs-1os = self.packages.${system};
          lib1os = self.lib1os.${system};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          modules = nixpkgs.lib.flatten [
            sops-nix.nixosModules.sops
            ./configuration.nix
            (import ./modules/all-modules.nix)
            host.modules
          ];

          specialArgs = {
            inherit
              pkgs-unstable
              pkgs-1os
              lib1os
              inputs
              ;
            oneos-name = name;
          };
        }
      ) hosts;

      modules = builtins.listToAttrs (
        map (path: {
          name = nixpkgs.lib.removeSuffix ".nix" (baseNameOf (toString path));
          value = path;
        }) (import ./modules/all-modules.nix)
      );
    };
}
