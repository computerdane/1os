{
  hosts = {
    bludgeonder = {
      system = "x86_64-linux";
      mac = "fc:aa:14:0e:54:c7";
    };
    fishtank = {
      system = "x86_64-linux";
      mac = "9c:6b:00:2f:0e:be";
    };
    limbo = {
      system = "x86_64-linux";
      mac = "2c:f0:5d:26:99:b0";
    };
    eefan.system = "x86_64-linux";
    shmacbook = {
      system = "aarch64-darwin";
      mac = "80:65:7c:e5:bf:cb";
      homeManagerOnly = true;
    };
  };

  home = {
    "dane@bludgeonder" = [ ];
    "dane@eefan" = [
      ./homeconfigs/pc.nix
      ./homeconfigs/hll/home.nix
    ];
    "dane@fishtank" = [
      ./homeconfigs/pc.nix
      ./homeconfigs/hll/home.nix
      # ./homeconfigs/soundboard.nix
    ];
    "dane@limbo" = [ ./homeconfigs/pc.nix ];
    "dane@shmacbook" = [ ./homeconfigs/laptop.nix ];
  };
}
