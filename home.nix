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

  (onix.lib.mapHostUser {

    "fishtank limbo eefan".dane = {
      oneos = {
        gaming.enable = true;
        hll.enable = true;
        kde.enable = true;
        media.enable = true;
        wallpapers.enable = true;
      };
    };

    fishtank.dane = {
      oneos = {
        development.enable = true;
        social.enable = true;
      };
    };

    fishtank."john aria scott allie" = {
      oneos.kde.enable = true;
    };

    shmacbook.dane = {
      oneos = {
        development.enable = true;
        media.enable = true;
        social.enable = true;
      };
    };

  })

]
