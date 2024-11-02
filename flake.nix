{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
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
            dynamic-dns = {
              enable = true;
              root = true;
              ipv4 = true;
            };
            factorio-server.enable = true;
            gateway.enable = true;
            vault.enable = true;

          };
        };

        fishtank = {
          system = "x86_64-linux";
          modules = [ ./hardware/fishtank.nix ];
          config.oneos = {

            auto-update.pull = true;
            desktop.enable = true;
            dynamic-dns.enable = true;
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
            sops-nix.nixosModules.sops

            ./modules/acme.nix
            ./modules/auto-update.nix
            ./modules/desktop.nix
            ./modules/domains.nix
            ./modules/dynamic-dns.nix
            ./modules/factorio-server.nix
            ./modules/gaming.nix
            ./modules/gateway.nix
            ./modules/nginx.nix
            ./modules/quilt-server.nix
            ./modules/vault.nix

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
            lib1os = pkgs-1os.lib1os;
          };
        }
      ) hosts;
    };
}
