{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
in
{
  home.packages =
    (with pkgs.unstable; [ nixd ])
    ++ (
      with pkgs;
      [
        aria2
        asciiquarium
        curl
        dua
        ffmpeg-full
        gitui
        hll-arty-calc
        hll-arty-tui
        jq
        mc-quick
        netcat
        nil
        nixfmt-rfc-style
        nmap
        pv
        ranger
        ripgrep
        shell-gpt
        tldr
        tree
        unzip
        uutils-coreutils
        wget
        wireguard-tools
        zip
      ]
      ++ (with fishPlugins; [
        colored-man-pages
        puffer
        tide
      ])
    )
    ++ (if stdenv.isLinux then with pkgs; [ ghostty ] else [ ]);

  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Dracula";
      theme_background = false;
      update_ms = 100;
    };
  };

  programs.computerdane-helix = {
    enable = true;
    package = pkgs.unstable.helix;
    defaultEditor = true;
    languages.nix.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.fish = lib.mkMerge [
    {
      enable = true;
      shellInit = ''
        set fish_greeting
        if test -e ~/.openai-api-key
          export OPENAI_API_KEY=$(cat ~/.openai-api-key)
        end
      '';
      shellAliases = {
        bop = "nix run github:computerdane/bop-bun --";
        cat = "bat";
        gpt = "sgpt";
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
        rivals-kill-switch = "pkill -9 Xwayland && XAUTHORITY=/run/user/1000/xauth* DISPLAY=:0 steam steam://rungameid/2767030";
        vpn = "sudo ip netns exec pvpn";
      };
    })
  ];

  programs.git = lib.mkIf (config.home.username == "dane") {
    enable = true;
    userName = "Dane Rieber";
    userEmail = "danerieber@gmail.com";
    extraConfig.init.defaultBranch = "main";
  };

  programs.ssh = {
    enable = true;
    matchBlocks."nf6.sh".port = 105;
    matchBlocks."knightf6.com".port = 105;
  };

  home.editable-file.".config/shell_gpt/.sgptrc".text = ''
    DEFAULT_MODEL=gpt-4o
  '';

  home.file.".config/ghostty/config".text = ''
    theme = Dracula
    background-opacity = 0.9
    maximize = true
  '';

  # Use fish shell on systems with bash or zsh
  home.file.".profile".text = "fish";
  home.file.".zshrc".text = "fish";

  home.homeDirectory =
    if stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
