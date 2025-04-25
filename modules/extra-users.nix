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

    users.users.scott = with config.thots.scott; {
      isNormalUser = true;
      inherit hashedPassword;
      openssh.authorizedKeys.keys = sshKeysList;
      shell = pkgs.${shell};
    };

  };
}
