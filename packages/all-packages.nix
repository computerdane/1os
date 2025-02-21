{ callPackage }:

{
  lib1os = callPackage ./lib1os.nix { };
  mc-quick = callPackage ./mc-quick.nix { };
}
