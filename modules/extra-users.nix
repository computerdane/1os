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
      lib.mapAttrs
        (
          name: thot: with thot; {
            isNormalUser = true;
            inherit hashedPassword;
            openssh.authorizedKeys.keys = sshKeysList;
            shell = pkgs.${shell};
          }
        )
        (
          lib.filterAttrs (
            name: _:
            builtins.elem name [
              "allie"
              "aria"
              "ethan"
              "john"
              "mason"
              "scott"
            ]
          ) config.thots
        );

    programs.zsh.enable = true; # zsh users need this enabled

  };
}
