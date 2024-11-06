{ config, lib, ... }:

let
  cfg = config.oneos.file-share;
in
{
  options.oneos.file-share.enable = lib.mkEnableOption "file-share";

  config = lib.mkIf cfg.enable {
    services.diod = {
      enable = true;
      exports = [ "/nas/share" ];
      userdb = true;
    };
  };
}
