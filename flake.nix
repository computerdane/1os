{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      hosts = import ./hosts.nix;
      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ]; # for vintagestory
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        imports = with flake-parts.flakeModules; [
          easyOverlay
          partitions
        ];

        flake = {
          nixosModules = import ./modules;
          homeModules = import ./homemodules;
          overlays.vintagestory_latest = _: prev: {
            vintagestory = prev.vintagestory.overrideDerivation (_: rec {
              version = "1.20.8";
              src = prev.fetchurl {
                url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                hash = "sha256-IINeXUpW894ipgyEB6jYcmeImIFLzADI+jIX6ADthH8=";
              };
            });
          };
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
                  packages = (import ./pkgs { inherit (pkgs) callPackage; });
                  overlayAttrs = config.packages // (import ./legacypkgs { inherit (pkgs) lib; });
                };
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
                            nixpkgs.config = nixpkgsConfig;
                            nixpkgs.overlays =
                              let
                                overlays = (builtins.attrValues config.flake.overlays);
                              in
                              overlays
                              ++ [
                                (_: _: {
                                  unstable = import inputs.nixpkgs-unstable {
                                    inherit system overlays;
                                    config = nixpkgsConfig;
                                  };
                                })
                              ];
                          }
                        )
                      ];
                      specialArgs.nixpkgs-unstable = inputs.nixpkgs-unstable;
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
                  pkgs = import inputs.nixpkgs {
                    system = hosts.hosts.${hostname}.system;
                    config = nixpkgsConfig;
                    overlays = builtins.attrValues config.flake.overlays;
                  };
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
                        }
                      )
                    ];
                }
              ) hosts.home;
            };
        };
      }
    );
}
