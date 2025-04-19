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

    home.packages = with pkgs.fishPlugins; [
      puffer
      tide
    ];

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
          my-tide-configure = "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Light --prompt_spacing=Sparse --icons='Few icons' --transient=No";
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
