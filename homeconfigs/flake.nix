{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-tls-501.url = "github:NixOS/nixpkgs/ac72a273c6022b0761c78a32837d71474d2875fa";
    home-manager.url = "github:nix-community/home-manager";
    plasma-manager.url = "github:nix-community/plasma-manager";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };
  outputs = { ... }: { };
}
