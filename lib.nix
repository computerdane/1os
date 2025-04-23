{ nixpkgs, systems }:
rec {
  isPure = !(builtins ? currentSystem);

  syspkgsWithConfig =
    nixpkgsConfig:
    if !isPure then
      import <nixpkgs> nixpkgsConfig
    else
      throw "Cannot use lib.syspkgsWithConfig or lib.syspkgs in pure eval mode";
  syspkgs = syspkgsWithConfig { };

  lib = if isPure then nixpkgs.lib else syspkgs.lib;

  eachSystem =
    f:
    if isPure then
      builtins.listToAttrs (
        builtins.map (system: {
          name = system;
          value =
            let
              pkgs = import nixpkgs { inherit system; };
            in
            f pkgs;
        }) systems
      )
    else
      {
        ${syspkgs.system} = f syspkgs;
      };

  filterAttrsNameMatches =
    regex: attrs: lib.filterAttrs (name: _: (builtins.match regex name) != null) attrs;

  makeIt =
    {
      nixpkgsConfig ? { },
      nixosModules ? [ ],
      homeModules ? [ ],
      nixosModulesByName ? (name: [ ]),
    }:
    {
      nixos ? [ ],
      home ? [ ],
    }:
    if !isPure then
      let
        inherit (builtins)
          attrNames
          elemAt
          filter
          hasAttr
          listToAttrs
          mapAttrs
          split
          ;
        inherit (lib) flatten mapAttrs' nameValuePair;

        pkgs = syspkgsWithConfig nixpkgsConfig;
      in
      {
        nixosConfigurations = mapAttrs (
          hostname: modules:
          pkgs.nixos {
            imports = modules ++ nixosModules ++ (nixosModulesByName hostname);
            networking.hostName = lib.mkForce hostname;
          }
        ) nixos;
        homeConfigurations =
          let
            userHostModules = filterAttrsNameMatches ''^.+'.+$'' home;

            defaultUserModules = mapAttrs' (sel: modules: nameValuePair (elemAt (split "'" sel) 0) modules) (
              filterAttrsNameMatches ''^.+'$'' home
            );
            defaultHostModules = filterAttrsNameMatches ''^[^']+$'' home;
            defaultUsers = attrNames defaultUserModules;
            defaultHosts = (attrNames defaultHostModules) ++ (attrNames nixos);

            pairs = flatten (map (user: map (host: "${user}'${host}") defaultHosts) defaultUsers);
            unmatchedPairs = filter (sel: !(hasAttr sel userHostModules)) pairs;
            unmatchedPairsAttrs = listToAttrs (
              map (sel: {
                name = sel;
                value = [ ];
              }) unmatchedPairs
            );
          in
          mapAttrs' (
            sel: modules:
            let
              tokens = (split "'" sel);
              username = elemAt tokens 0;
              hostname = elemAt tokens 2;
            in
            nameValuePair "${username}@${hostname}" (
              import <home-manager/modules> {
                inherit pkgs;
                configuration = {
                  imports =
                    modules
                    ++ homeModules
                    ++ defaultHostModules.${hostname} or [ ]
                    ++ defaultUserModules.${username} or [ ];
                  home.username = lib.mkForce username;
                  nixpkgs = nixpkgsConfig;
                };
              }
            )
          ) (userHostModules // unmatchedPairsAttrs);
      }
    else
      { };
}
