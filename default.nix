let
  lib = import ./lib.nix;
in

lib.makeIt {
  fishtank = [
    ./configs/fishtank/configuration.nix
    ./configs/fishtank/hardware-configuration.nix
  ];

  "dane@fishtank" = [
    ./homeconfigs/full.nix
    ./homeconfigs/hll/home.nix
    ./homeconfigs/kde.nix
    ./homeconfigs/wallpapers/home.nix
  ];

  "dane@shmacbook" = [
    ./homeconfigs/full.nix
  ];
}
