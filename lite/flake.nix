{
  inputs = {
    nixpkgs = {
      type = "indirect";
      id = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    parent.url = "path:..";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      parent,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem =
        f:
        builtins.listToAttrs (
          builtins.map (system: {
            name = system;
            value = f (
              import nixpkgs {
                inherit system;
                config = {
                  allowUnfree = true;
                  permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ]; # for vintagestory
                };
                overlays = builtins.attrValues parent.overlays;
              }
            );
          }) systems
        );
    in
    {
      legacyPackages = eachSystem (pkgs: {
        homeConfigurations.dane = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = (builtins.attrValues parent.homeModules) ++ [
            ../home.nix
            (
              { lib, ... }:
              {
                home.username = lib.mkForce "dane";
              }
            )
          ];
        };
      });
    };
}
