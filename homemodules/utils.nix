{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs) stdenv;
  cfg = config.oneos.utils;

  ghosttySettings = {
    theme = "catppuccin-mocha";
    background-opacity = 0.9;
    maximize = true;
  };
in
{
  options.oneos.utils.enable = lib.mkEnableOption "utils";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      dua
      jq
      pv
      ranger
      ripgrep
      tldr
      tree
      unzip
      uutils-coreutils
      wireguard-tools
      zip
    ];

    programs.bat.enable = true;
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.git.enable = true;
    programs.nix-index.enable = true;
    programs.ssh.enable = true;
    programs.tmux.enable = true;
    programs.zoxide.enable = true;

    programs.btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha";
        theme_background = false;
        update_ms = 100;
      };
    };
    xdg.configFile."btop/themes" = {
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

    programs.computerdane-helix = {
      enable = true;
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

    programs.ghostty = lib.mkIf stdenv.isLinux {
      enable = true;
      settings = ghosttySettings;
    };
    xdg.configFile."ghostty/config" =
      with lib;
      mkIf stdenv.isDarwin {
        text = mkIf stdenv.isDarwin (
          concatStringsSep "\n" (mapAttrsToList (name: value: "${name} = ${toString value}") ghosttySettings)
        );
      };

  };
}
