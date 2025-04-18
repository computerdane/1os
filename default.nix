let
  lib = import ./lib.nix;
in

lib.makeIt {
  nixos = {
    fishtank = [
      ./configs/fishtank/configuration.nix
      ./configs/fishtank/hardware-configuration.nix
    ];
  };

  home = {
    "dane@fishtank" = [
      ./hm-configs/full.nix
      ./hm-configs/hll.nix
      ./hm-configs/kde.nix
      ./hm-configs/wallpapers.nix
    ];

    "dane@shmacbook" = [
      ./hm-configs/full.nix
    ];
  };
}
