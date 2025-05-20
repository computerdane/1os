{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    thothub.url = "github:computerdane/thothub";
    fossai.url = "github:computerdane/fossai/nix-module";

    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { ... }: { };
}
