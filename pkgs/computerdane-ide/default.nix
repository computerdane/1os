{
  helix,
  nnn,
  nushell,
  tmux,
  writeShellApplication,
}:

writeShellApplication {
  name = "computerdane-ide";
  runtimeInputs = [
    helix
    nnn
    nushell
    tmux
  ];
  text = ''
    tmux new-session "NNN_OPENER=${./opener.nu} nnn -c"
  '';
}
