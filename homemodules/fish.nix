{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.fish;
in
{
  options.oneos.fish =
    with lib;
    with types;
    {
      enable = mkEnableOption "fish";
    };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.fishPlugins.puffer ];
    programs.starship.enable = true;

    programs.fish = lib.mkMerge [
      {
        enable = true;
        shellInit = lib.mkIf config.programs.shell-gpt.enable (
          let
            loadSecret = varName: fileName: ''
              if test -e ~/.${fileName}
                export ${varName}=$(cat ~/.${fileName})
              end
            '';
          in
          ''
            set fish_greeting
            ${loadSecret "OPENAI_API_KEY" "litellm-api-key"}
            ${loadSecret "GEMINI_API_KEY" "gemini-api-key"}
          ''
        );
        shellAliases = {
          cat = "bat";
          gpt = lib.mkIf config.programs.shell-gpt.enable "sgpt";
        };
      }
      (lib.mkIf stdenv.isLinux {
        shellInit = ''
          complete -w journalctl logs
          complete -w "systemctl status" logs
          complete -w journalctl flogs
          complete -w "systemctl status" flogs
        '';
        shellAliases = {
          logs = "journalctl --no-hostname -aeu";
          flogs = "journalctl --no-hostname -afu";
          vpn = "sudo ip netns exec pvpn";
        };
      })
    ];

    # Use fish shell on systems with bash or zsh
    home.file = lib.mkIf stdenv.isDarwin {
      ".profile".text = "fish";
      ".zshrc".text = "fish";
    };

  };
}
