{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      hosts = import ./hosts.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        imports = with flake-parts.flakeModules; [
          easyOverlay
          partitions
        ];

        flake = {
          nixosModules = import ./modules/all-modules.nix;
          homeModules = import ./homemodules/all-modules.nix;
        };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        partitionedAttrs.packages = "pkgs";
        partitionedAttrs.overlays = "pkgs";
        partitions.pkgs = {
          extraInputsFlake = ./pkgs;
          module =
            { ... }:
            {
              perSystem =
                { config, pkgs, ... }:
                {
                  packages = (import ./pkgs/all-packages.nix { inherit (pkgs) callPackage; });
                  overlayAttrs = config.packages // (import ./legacypkgs/all-packages.nix { inherit (pkgs) lib; });
                };
            };
        };

        partitionedAttrs.homeConfigurations = "homeconfigs";
        partitions.homeconfigs = {
          extraInputsFlake = ./homeconfigs;
          module =
            { inputs, ... }:
            {
              flake.homeConfigurations = builtins.mapAttrs (
                name: modules:
                let
                  tokens = builtins.split "@" name;
                  username = builtins.elemAt tokens 0;
                  hostname = builtins.elemAt tokens 2;
                in
                inputs.home-manager.lib.homeManagerConfiguration {
                  pkgs = import inputs.nixpkgs { system = hosts.hosts.${hostname}.system; };
                  modules =
                    (builtins.attrValues config.flake.homeModules)
                    ++ modules
                    ++ [
                      inputs.plasma-manager.homeManagerModules.plasma-manager
                      ./home.nix
                      (
                        { lib, ... }:
                        {
                          home.username = lib.mkForce username;
                          nixpkgs.overlays = [ config.flake.overlays.default ];
                        }
                      )
                    ];
                }
              ) hosts.home;
            };
        };

        partitionedAttrs.nixosConfigurations = "configs";
        partitions.configs = {
          extraInputsFlake = ./configs;
          module =
            { inputs, ... }:
            {
              flake.nixosConfigurations =
                builtins.mapAttrs
                  (
                    hostname:
                    { system, ... }:
                    inputs.nixpkgs.lib.nixosSystem {
                      inherit system;
                      modules = (builtins.attrValues config.flake.nixosModules) ++ [
                        inputs.sops-nix.nixosModules.sops
                        ./configuration.nix
                        "${./.}/configs/${hostname}/configuration.nix"
                        "${./.}/configs/${hostname}/hardware-configuration.nix"
                        (
                          { lib, ... }:
                          {
                            networking.hostName = lib.mkForce hostname;
                            nixpkgs.overlays = [ config.flake.overlays.default ];
                          }
                        )
                      ];
                    }
                  )
                  (
                    inputs.nixpkgs.lib.filterAttrs (
                      _:
                      {
                        homeManagerOnly ? false,
                        ...
                      }:
                      !homeManagerOnly
                    ) hosts.hosts
                  );
            };
        };
      }
    );
}
