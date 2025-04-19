rec {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (_: _: { unstable = import <nixpkgs-unstable> { }; })
      (final: prev: import ./packages/all-packages.nix { pkgs = prev; })
    ];
  };

  pkgs = import <nixpkgs> nixpkgs;

  makeIt = builtins.mapAttrs (
    name: value:
    if (builtins.match "^.+@.+$" name) != null then
      let
        username = builtins.elemAt (builtins.split "@" name) 0;
      in
      {
        inherit nixpkgs;
        imports =
          value
          ++ import ./homemodules/all-modules.nix
          ++ [
            <plasma-manager/modules>
            ./home.nix
          ];
        home.username = username;
      }
    else
      pkgs.nixos {
        networking.hostName = name;
        imports =
          value
          ++ import ./modules/all-modules.nix
          ++ [
            <sops-nix/modules/sops>
            ./configuration.nix
          ];
      }
  );
}
