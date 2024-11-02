{ callPackage }:

{
  lib1os = callPackage ./lib1os.nix { };
  quilt-server = callPackage ./quilt-server.nix { };
}
