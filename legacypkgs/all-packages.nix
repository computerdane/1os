{ lib }:
{
  lib1os = import ./lib1os.nix { inherit lib; };
}
