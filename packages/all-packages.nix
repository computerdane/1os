{ pkgs }:

{
  bop = pkgs.callPackage ./bop.nix { };
  digirain = pkgs.callPackage ./digirain.nix { };
  hll-arty-calc = pkgs.callPackage ./hll-arty-calc.nix { };
  lib1os = pkgs.callPackage ./lib1os.nix { };
  mc-quick = pkgs.callPackage ./mc-quick.nix { };
}
