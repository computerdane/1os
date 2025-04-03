{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.utils;
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
    programs.ssh.enable = true;
    programs.tmux.enable = true;
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

  };
}
