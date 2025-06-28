{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.nushell;
in
{
  options.oneos.nushell.enable = lib.mkEnableOption "nushell";

  config = lib.mkIf cfg.enable {

    programs.nushell = {
      enable = true;
      shellAliases = {
        gpt = lib.mkIf config.programs.shell-gpt.enable "sgpt";
        ll = "ls -l";
        sops-hostkey = "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age";
        sops-keygen = "mkdir ~/.config/sops/age; age-keygen -o ~/.config/sops/age/keys.txt";
      };
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.direnv.enableNushellIntegration = true;

    # Needed for nix command autocomplete
    home.packages = [ pkgs.sqlite ];

    home.shell.enableNushellIntegration = true;

    # Use nushell shell on systems with bash or zsh
    home.file = lib.mkIf stdenv.isDarwin {
      ".profile".text = "nushell";
      ".zshrc".text = "nushell";
    };

  };
}
