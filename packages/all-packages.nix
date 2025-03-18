{ callPackage }:

{
  hll-arty-calc = callPackage ./hll-arty-calc.nix { };
  mc-quick = callPackage ./mc-quick.nix { };
}
