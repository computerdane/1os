{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.extra-users;
in
{
  options.oneos.extra-users.enable = lib.mkEnableOption "extra-users";

  config = lib.mkIf cfg.enable {

    users.users.john = {
      isNormalUser = true;
      initialPassword = "abc123";
      extraGroups = [ "network" ];
      shell = pkgs.fish;
    };

    users.users.aria = {
      isNormalUser = true;
      initialPassword = "abc123";
      extraGroups = [ "network" ];
      shell = pkgs.fish;
    };

  };
}
