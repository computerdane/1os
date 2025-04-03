{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
in
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

  programs.home-manager.enable = true;
}
