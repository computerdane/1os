let
  lib = import ./lib.nix;
in

lib.makeIt (self: {
  fishtank = [ ];
  bludgeonder = [ ];
  limbo = [ ];
  eefan = [ ];

  "dane@fishtank" = [
    ./homeconfigs/full.nix
    ./homeconfigs/hll/home.nix
    ./homeconfigs/kde.nix
    ./homeconfigs/wallpapers/home.nix
  ];
  "dane@limbo" = self."dane@fishtank";

  "dane@bludgeonder" = [];

  "dane@shmacbook" = [
    ./homeconfigs/full.nix
  ];
})
