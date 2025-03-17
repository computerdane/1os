{ callPackage }:

{
  lib1os = callPackage ./lib1os.nix { };

  hll-arty-calc = callPackage ./hll-arty-calc.nix { };
  mc-quick = callPackage ./mc-quick.nix { };
}
