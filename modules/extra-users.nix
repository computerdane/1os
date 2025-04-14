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

    users.users =
      let
        defaultUser = {
          isNormalUser = true;
          initialPassword = "abc123";
          extraGroups = [ "network" ];
          shell = pkgs.fish;
        };
      in
      {
        allie = defaultUser;
        aria = defaultUser;
        john = defaultUser;
        scott = defaultUser;
      };

  };
}
