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
  options.oneos.nushell = {
    enable = lib.mkEnableOption "nushell";
    defaultShell = lib.mkEnableOption "default shell";
  };

  config = lib.mkIf cfg.enable {

    programs.nushell = {
      enable = true;
      shellAliases = {
        gpt = lib.mkIf config.programs.shell-gpt.enable "sgpt";
        ll = "ls -l";
        lla = "ls -la";
        sops-hostkey = lib.mkIf stdenv.isLinux "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age";
        sops-keygen = lib.mkIf stdenv.isLinux "mkdir ~/.config/sops/age; age-keygen -o ~/.config/sops/age/keys.txt";
        logs = "journalctl --no-hostname -aeu";
        flogs = "journalctl --no-hostname -afu";
        vpn = "sudo ip netns exec pvpn";
        cat = "bat";
      };
      environmentVariables = config.home.sessionVariables;

      settings.completions = {
        case_sensitive = false;
        algorithm = "fuzzy";
        external = {
          enable = true;
          max_results = 200;
        };
      };

      # https://www.nushell.sh/cookbook/external_completers.html#fish-completer
      # https://github.com/nushell/nushell/issues/10285#issuecomment-2731825727
      extraEnv = ''
        let fish_completer = {|spans|
            let completions = fish --command $'complete "--do-complete=($spans | str join " ")"'
            | from tsv --flexible --noheaders --no-infer
            | rename value description

            let has_paths = ($completions | any {|row| $row.value =~ '/' or $row.value =~ '\\.\\w+$' or $row.value =~ ' '})

            if $has_paths {
                $completions | update value {|row|
                    if $row.value =~ ' ' {
                        $"'($row.value)'"  # Wrap in single quotes
                    } else {
                        $row.value
                    }
                }
            } else {
                $completions
            }
        }
      '';

      extraConfig = ''
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

    # Use nushell on systems with bash or zsh
    home.file = lib.mkIf (stdenv.isDarwin && cfg.defaultShell) {
      ".profile".text = "nu";
      ".zshrc".text = "nu";
    };

  };
}
