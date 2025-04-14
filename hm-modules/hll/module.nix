{ config, lib, ... }:

let
  cfg = config.oneos.hll;
in
{
  options.oneos.hll.enable = lib.mkEnableOption "Hell Let Loose settings";

  config = lib.mkIf cfg.enable {

    home.editable-file =
      let
        dir = ".local/share/Steam/steamapps/compatdata/686810/pfx/drive_c/users/steamuser/AppData/Local/HLL/Saved/Config/WindowsNoEditor";
      in
      {
        "${dir}/GameUserSettings.ini".source = ./GameUserSettings.ini;
        "${dir}/Input.ini".source = ./Input.ini;
      };

  };
}
