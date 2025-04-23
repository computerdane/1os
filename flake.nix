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
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ];
            };
            overlays = [
              (_: _: {
                unstable = import <nixpkgs-unstable> {
                  inherit config;
                  overlays = [
                    overlay
                    (_: prev: {
                      vintagestory = (
                        prev.vintagestory.overrideDerivation (_: rec {
                          version = "1.20.8";
                          src = prev.fetchurl {
                            url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                            hash = "sha256-IINeXUpW894ipgyEB6jYcmeImIFLzADI+jIX6ADthH8=";
                          };
                        })
                      );
                    })
                  ];
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
