{
  development = import ./development.nix;
  editable-file = import ./editable-file.nix;
  nushell = import ./nushell.nix;

  computerdane-helix = import ./programs/computerdane-helix.nix;
  shell-gpt = import ./programs/shell-gpt.nix;
}
