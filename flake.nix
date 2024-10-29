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
    let
      hosts = {

        bludgeonder = {
          system = "x86_64-linux";
          modules = [ ./hardware/bludgeonder.nix ];
          config.oneos = {

            auto-update = {
              pull = true;
              push = true;
            };
            factorio-server.enable = true;
            gateway.enable = true;

          };
        };

        fishtank = {
          system = "x86_64-linux";
          modules = [ ./hardware/fishtank.nix ];
          config.oneos = {

            auto-update.pull = true;
            desktop.enable = true;
            gaming.enable = true;

          };
        };

      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
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

            ./features/auto-update.nix
            ./features/desktop.nix
            ./features/factorio-server.nix
            ./features/gaming.nix
            ./features/gateway.nix
            ./features/quilt-server.nix

            (
              { ... }:
              {
                networking.hostName = name;
              }
            )

            ({ ... }: config)

          ] ++ modules;
          specialArgs = {
            inherit pkgs-unstable pkgs-1os;
          };
        }
      ) hosts;
    };
}
