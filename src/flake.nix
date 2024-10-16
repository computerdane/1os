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
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
    in
    {
      nixosConfigurations."1os" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          /etc/nixos/hardware-configuration.nix
          ./configuration.nix
        ];
        specialArgs = {
          inherit pkgs-unstable;
        };
      };
    };
}
