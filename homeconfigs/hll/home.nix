{ ... }:

let
  dir = ".local/share/Steam/steamapps/compatdata/686810/pfx/drive_c/users/steamuser/AppData/Local/HLL/Saved/Config/WindowsNoEditor";
in
{
  home.editable-file."${dir}/GameUserSettings.ini".source = ./GameUserSettings.ini;
  home.editable-file."${dir}/Input.ini".source = ./Input.ini;
}
