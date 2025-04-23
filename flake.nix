{
  outputs =
    { self, nixpkgs }:
    let
      lib = import ./lib.nix {
        inherit nixpkgs;
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
      };
      importPackages = pkgs: import ./pkgs/all-packages.nix { inherit (pkgs) callPackage; };
      importLegacyPackages = pkgs: import ./legacypkgs/all-packages.nix { inherit (pkgs) lib; };
      overlay = _: prev: ((importPackages prev) // (importLegacyPackages prev));
    in
    {
      devShells = lib.eachSystem (pkgs: {
        default = import ./shell.nix { inherit pkgs; };
      });
      packages = lib.eachSystem importPackages;
      legacyPackages = lib.eachSystem importLegacyPackages;
      overlays.default = overlay;
      nixosModules = import ./modules/all-modules.nix;
      homeModules = import ./homemodules/all-modules.nix;
    }
    // (
      let
        itConfig = {
          nixpkgsConfig = rec {
            config.allowUnfree = true;
            overlays = [
              (_: _: {
                unstable = import <nixpkgs-unstable> {
                  inherit config;
                  overlays = [ overlay ];
                };
              })
              overlay
            ];
          };
          nixosModules = (builtins.attrValues self.nixosModules) ++ [
            <sops-nix/modules/sops>
            ./configuration.nix
          ];
          homeModules = (builtins.attrValues self.homeModules) ++ [
            ./home.nix
          ];
          nixosModulesByName = name: [
            "${./.}/configs/${name}/configuration.nix"
            "${./.}/configs/${name}/hardware-configuration.nix"
          ];
        };
        it = import ./it.nix;
      in
      lib.makeIt itConfig it
    );
}
