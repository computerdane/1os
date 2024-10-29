{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    {
      nixosConfigurations =
        builtins.mapAttrs
          (
            name: cfg:
            with cfg;
            let
              pkgs = import nixpkgs { inherit system; };
              pkgs-unstable = import nixpkgs-unstable { inherit system; };
              pkgs-1os = pkgs.callPackage ./packages/all-packages.nix { };
            in
            nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                ./configuration.nix
                (
                  { ... }:
                  {
                    networking.hostName = name;
                  }
                )
              ] ++ modules;
              specialArgs = {
                inherit pkgs-unstable pkgs-1os;
              };
            }
          )
          {
            fishtank = {
              system = "x86_64-linux";
              modules = [
                ./hardware/fishtank.nix

                ./features/desktop.nix
                ./features/gaming.nix
              ];
            };
            bludgeonder = {
              system = "x86_64-linux";
              modules = [
                ./hardware/bludgeonder.nix

                ./features/auto-update/pull.nix
                ./features/auto-update/push.nix

                ./features/gateway.nix

                ./features/factorio-server.nix
                ./features/quilt-server.nix
              ];
            };
          };
    };
}
