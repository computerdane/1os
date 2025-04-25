{
  development = import ./development.nix;
  editable-file = import ./editable-file.nix;
  fish = import ./fish.nix;
  gaming = import ./gaming.nix;
  media = import ./media.nix;
  net-utils = import ./net-utils.nix;
  social = import ./social.nix;
  utils = import ./utils.nix;

  bop = import ./programs/bop.nix;
  computerdane-helix = import ./programs/computerdane-helix.nix;
  shell-gpt = import ./programs/shell-gpt.nix;
}
