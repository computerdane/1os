{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    onix.url = "github:computerdane/onix/no-more-flakes";
    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs =
    {
      nixpkgs,
      onix,
      sops-nix,
      ...
    }:
    onix.init {
      inherit nixpkgs;
      src = ./.;
      extraModules = [ sops-nix.nixosModules.sops ];
      nixpkgsConfig.allowUnfree = true;
    };
}
