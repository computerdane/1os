let
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (_: _: {
        unstable = import <nixpkgs-unstable> { };
        dane = import <nixpkgs-dane> { };
      })
    ];
  };
  pkgs = import <nixpkgs> nixpkgs;
in
{
  makeIt =
    it:
    builtins.mapAttrs (
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
        let
          modules =
            if value == [ ] then
              [
                "${./.}/configs/${name}/configuration.nix"
                "${./.}/configs/${name}/hardware-configuration.nix"
              ]
            else
              value;
        in
        pkgs.nixos {
          networking.hostName = name;
          imports =
            modules
            ++ import ./modules/all-modules.nix
            ++ [
              <sops-nix/modules/sops>
              ./configuration.nix
            ];
        }
    ) (it (it null));
}
