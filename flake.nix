{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = { nixpkgs, ... }: import ./default.nix { inherit nixpkgs; };
}
