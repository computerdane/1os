{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;

  ghosttySettings = {
    theme = "catppuccin-mocha";
    background-opacity = 0.9;
    maximize = true;
    font-family = "ComicShannsMono Nerd Font";
  };
in
{

  oneos.nushell.enable = true;

  home = {

    packages = with pkgs; [
      aria2
      curl
      dua
      ffmpeg-full
      fishPlugins.puffer
      jq
      netcat
      nmap
      pv
      ranger
      ripgrep
      tldr
      tree
      unzip
      uutils-coreutils
      wget
      wireguard-tools
      zip
    ];

    file.".profile".text = lib.mkIf stdenv.isDarwin "nu";
    file.".zshrc".text = lib.mkIf stdenv.isDarwin "nu";

    homeDirectory = "/${if stdenv.isDarwin then "Users" else "home"}/${config.home.username}";

    stateVersion = "24.05";

  };

  programs = {

    bat.enable = true;
    fd.enable = true;
    fzf.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;
    ssh.enable = true;
    starship.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha";
        theme_background = false;
        update_ms = 100;
      };
    };

    computerdane-helix = {
      enable = true;
      defaultEditor = true;
      languages.nix.enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };

    fish = lib.mkMerge [

      {
        enable = true;
        shellAliases = {
          cat = "bat";
          gpt = "OPENAI_API_KEY=$(cat ~/.litellm-api-key) sgpt";
        };
      }

      (lib.mkIf stdenv.isLinux {
        shellAliases = {
          logs = "journalctl --no-hostname -aeu";
          flogs = "journalctl --no-hostname -afu";
          vpn = "sudo ip netns exec pvpn";
        };
        shellInit = ''
          complete -w "systemctl status" logs
          complete -w "systemctl status" flogs
        '';
      })

    ];

    ghostty = lib.mkIf stdenv.isLinux {
      enable = true;
      settings = ghosttySettings;
    };

    git = lib.mkMerge [

      { enable = true; }

      (lib.mkIf (config.home.username == "dane") {
        userName = "Dane Rieber";
        userEmail = "danerieber@gmail.com";
        extraConfig.init.defaultBranch = "main";
      })

    ];

    shell-gpt = {
      enable = true;
      settings = {
        API_BASE_URL = "https://llm.nf6.sh";
        DEFAULT_MODEL = "gpt-4.1";
      };
    };

  };

  xdg.configFile = {

    "btop/themes" = {
      source = "${
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "btop";
          rev = "1.0.0";
          hash = "sha256-J3UezOQMDdxpflGax0rGBF/XMiKqdqZXuX4KMVGTxFk=";
        }
      }/themes";
      recursive = true;
    };

    "ghostty/config" =
      with lib;
      mkIf stdenv.isDarwin {
        text = mkIf stdenv.isDarwin (
          concatStringsSep "\n" (mapAttrsToList (name: value: "${name} = ${toString value}") ghosttySettings)
        );
      };

  };

  nix.registry = import ./registry.nix;
}
