{ pkgs, ... }:

let
  sounds = ./sounds;
  hotkey = "Ctrl+Alt";
  play =
    filename: key:
    let
      script = pkgs.writeShellScript "play-${filename}.sh" ''
        pw-play --target vmic-in "${sounds}/${filename}.mp3" & disown
        pw-play "${sounds}/${filename}.mp3" & disown
      '';
    in
    {
      "play-${filename}" = {
        key = "${hotkey}+${key}";
        command = ''${script}'';
      };
    };
in
{

  programs.plasma = {
    enable = true;
    hotkeys.commands =
      (play "21" "T")
      // (play "bruh" "B")
      // (play "airhorn" "A")
      // (play "oh-my-god" "O")
      // (play "vine-boom" "V")
      // (play "taco-bell-bong" "G")
      // (play "metal-gear-alert" "M")
      // (play "snore-mimimimimimi" "S")
      // (play "and-his-name-is-john" "J")
      // (play "fnaf-2-hallway-noise" "F");
  };

}
