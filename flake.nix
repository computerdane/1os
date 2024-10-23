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
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
      pkgs-1os = pkgs.callPackage ./packages/all-packages.nix { };
    in
    {
      nixosConfigurations =
        builtins.mapAttrs
          (
            name: value:
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
              ] ++ value;
              specialArgs = {
                inherit pkgs-unstable pkgs-1os;
              };
            }
          )
          {
            pc = [
              ./hardware/pc.nix
              ./features/desktop.nix
              ./features/gaming.nix
            ];
            server = [
              ./hardware/server.nix
              ./features/server.nix
              ./features/server/factorio.nix
              ./features/server/quilt-server.nix
            ];
          };
    };
}
