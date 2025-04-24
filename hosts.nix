{
  hosts = {
    bludgeonder.system = "x86_64-linux";
    fishtank.system = "x86_64-linux";
    limbo.system = "x86_64-linux";
    eefan.system = "x86_64-linux";
    shmacbook = {
      system = "aarch64-darwin";
      homeManagerOnly = true;
    };
  };

  home =
    let
      danesDesktop = [
        ./homeconfigs/full.nix
        ./homeconfigs/hll/home.nix
        ./homeconfigs/kde.nix
      ];
    in
    {
      "dane@bludgeonder" = [ ];
      "dane@fishtank" = danesDesktop;
      "dane@limbo" = danesDesktop;
      "dane@eefan" = danesDesktop;
      "dane@shmacbook" = [ ./homeconfigs/full.nix ];
    };
}
