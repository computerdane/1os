{
  nixos = {
    bludgeonder = [ ];
    fishtank = [ ];
    limbo = [ ];
    eefan = [ ];
  };

  home = rec {
    dane' = [ ];

    dane'shmacbook = [ ./homeconfigs/full.nix ];

    fishtank = [
      <plasma-manager/modules>
      ./homeconfigs/kde.nix
    ];
    limbo = fishtank;
    eefan = fishtank;

    dane'fishtank = [
      ./homeconfigs/full.nix
      ./homeconfigs/hll/home.nix
      ./homeconfigs/wallpapers/home.nix
    ];
    dane'limbo = dane'fishtank;
    dane'eefan = dane'fishtank;
  };
}
