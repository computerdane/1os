{
  config,
  lib,
  onix,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
in
lib.mkMerge [

  {
    oneos = {
      fish.enable = true;
      net-utils.enable = true;
      utils.enable = true;
    };

    programs.git = lib.mkIf (config.home.username == "dane") {
      userName = "Dane Rieber";
      userEmail = "danerieber@gmail.com";
      extraConfig.init.defaultBranch = "main";
    };

    home.homeDirectory =
      if stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

    home.stateVersion = "24.05";

    nix.registry = import ./registry.nix;
  }

  (onix.lib.mkForHosts
    [
      "fishtank"
      "limbo"
      "eefan"
    ]
    {
      oneos =
        if onix.meta.user == "dane" then
          { profiles.danes-desktop.enable = true; }
        else
          { kde.enable = true; };
    }
  )

  (onix.lib.mkForHosts [ "shmacbook" ] { oneos.profiles.full.enable = true; })

]
