rec {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (_: _: { unstable = import <nixpkgs-unstable> { }; })
      (final: prev: import ./packages/all-packages.nix { pkgs = prev; })
    ];
  };

  modules = (import ./modules/all-modules.nix) ++ [
    "<sops-nix>/modules/sops"
  ];
  homeModules = (import ./hm-modules/all-modules.nix) ++ [
    "${<plasma-manager>}/modules"
    ./home.nix
  ];

  getHomeConfigs = builtins.mapAttrs (
    name: value:
    if (builtins.match "^.+@.+$" name) != null then
      let
        username = builtins.elemAt (builtins.split "@" name) 0;
      in
      {
        inherit nixpkgs;
        imports = homeModules ++ value;
        home.username = username;
      }
    else
      throw "Home Manager configs must be defined as user@host"
  );

  getNixosConfigs = builtins.mapAttrs (
    name: value: {
      inherit nixpkgs;
      imports = modules ++ value;
    }
  );

  makeIt = { nixos, home }: (getNixosConfigs nixos) // (getHomeConfigs home);
}
