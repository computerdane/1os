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
        sops-hostkey = lib.mkIf stdenv.isLinux "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age";
        sops-keygen = lib.mkIf stdenv.isLinux "mkdir ~/.config/sops/age; age-keygen -o ~/.config/sops/age/keys.txt";
      };
      environmentVariables = config.home.sessionVariables;

      settings.completions.external = {
        enable = true;
        max_results = 200;
      };

      # https://www.nushell.sh/cookbook/external_completers.html#fish-completer
      extraConfig = ''
        let fish_completer = {|spans|
            ${pkgs.fish}/bin/fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
            | from tsv --flexible --noheaders --no-infer
            | rename value description
            | update value {|row|
              let value = $row.value
              let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
              if ($need_quote and ($value | path exists)) {
                let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
                $'"($expanded_path | str replace --all "\"" "\\\"")"'
              } else {$value}
            }
        }
        $env.config.completions.external.completer = $fish_completer
      '';
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.direnv.enableNushellIntegration = true;

    # Needed for nix command autocomplete
    home.packages = [ pkgs.sqlite ];

    home.shell.enableNushellIntegration = true;

    # Use nushell shell on systems with bash or zsh
    home.file = lib.mkIf stdenv.isDarwin {
      ".profile".text = "nu";
      ".zshrc".text = "nu";
    };

  };
}
