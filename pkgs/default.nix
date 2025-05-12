{ callPackage }:
{
  bop = callPackage ./bop.nix { };
  digirain = callPackage ./digirain.nix { };
  hll-arty-calc = callPackage ./hll-arty-calc.nix { };
  hll-arty-tui = callPackage ./hll-arty-tui.nix { };
  mc-quick = callPackage ./mc-quick.nix { };
  shortcutmenu = callPackage ./shortcutmenu.nix { };
}
