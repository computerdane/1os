{ config, lib, ... }:

let
  cfg = config.oneos.profiles.full;
in
{
  options.oneos.profiles.full.enable = lib.mkEnableOption "profile: full";

  config = lib.mkIf cfg.enable {

    oneos = {
      development.enable = true;
      gaming.enable = true;
      media.enable = true;
      social.enable = true;
    };
    programs.shell-gpt.enable = true;

  };
}
