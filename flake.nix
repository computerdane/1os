{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    onix.url = "github:computerdane/onix/v0.1.0";
    plasma-manager.url = "github:nix-community/plasma-manager";
    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs =
    { ... }@inputs:
    with inputs;

    let
      unstableOverlayModule =
        { ... }:
        {
          nixpkgs.overlays = [
            (final: prev: { unstable = import nixpkgs-unstable { system = prev.system; }; })
          ];
        };
    in

    onix.init {
      inherit home-manager nixpkgs;
      src = ./.;
      extraModules = [
        sops-nix.nixosModules.sops
        unstableOverlayModule
      ];
      extraHomeManagerModules = [
        plasma-manager.homeManagerModules.plasma-manager
        unstableOverlayModule
      ];
    };
}
