{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    sops-nix.url = "github:Mic92/sops-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    onix.url = "github:computerdane/onix/home-manager";
    onixpkgs.url = "github:computerdane/onixpkgs/home-manager";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    plasma-manager.url = "github:nix-community/plasma-manager";

    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    onix.inputs.nixpkgs.follows = "nixpkgs";
    onixpkgs.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";

    onix.inputs.home-manager.follows = "home-manager";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      systems,
      sops-nix,
      treefmt-nix,
      onix,
      onixpkgs,
      plasma-manager,
      ...
    }:
    onix.init {
      src = ./.;
      modules = [
        sops-nix.nixosModules.sops
        (nixpkgs.lib.attrsets.attrValues onixpkgs.nixosModules)
      ];
      hmModules = [
        plasma-manager.homeManagerModules.plasma-manager
      ];
      overlays = {
        onixpkgs = onixpkgs.overlays.default;
        unstable = (final: prev: { unstable = import nixpkgs-unstable { system = prev.system; }; });
      };
    }
    // (
      let
        # Small tool to iterate over each systems
        eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      in
      {
        # for `nix fmt`
        formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
        # for `nix flake check`
        checks = eachSystem (pkgs: {
          formatting = treefmtEval.${pkgs.system}.config.build.check self;
        });
      }
    );
}
