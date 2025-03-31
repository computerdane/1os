{
  inputs = {
    hll-arty-tui.url = "github:computerdane/hll-arty-tui";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    onix.url = "github:computerdane/onix/v0.1.2";
    plasma-manager.url = "github:nix-community/plasma-manager";
    sops-nix.url = "github:Mic92/sops-nix";

    hll-arty-tui.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    { ... }@inputs:
    with inputs;

    let
      overlaysModule =
        { ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable { system = prev.system; };
              hll-arty-tui = hll-arty-tui.packages.${prev.system}.default;
            })
          ];
        };
    in

    onix.init {
      inherit home-manager nixpkgs;
      src = ./.;
      installHelperScripts = true;
      extraModules = [
        sops-nix.nixosModules.sops
        overlaysModule
      ];
      extraHomeManagerModules = [
        plasma-manager.homeManagerModules.plasma-manager
        overlaysModule
      ];
    }
    // {
      templates.new-project = {
        path = ./templates/new-project;
        description = "starter for new projects";
      };
    };
}
