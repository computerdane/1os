{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with types;

let
  pkgs-tls-501 = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ac72a273c6022b0761c78a32837d71474d2875fa";
    hash = "sha256-xR9Hx5KbM9daoPzaoAdrnQQkQKPPaQQl7ulZbe9lLKc=";
  }) { system = pkgs.system; };

  cfg = config.programs.computerdane-helix;

  baseConfig = {
    enable = true;
    package = cfg.package;
    defaultEditor = cfg.defaultEditor;
    themes = {
      "${cfg.theme}_nobg" = {
        inherits = cfg.theme;
        "ui.background" = "{}";
      };
    };
    settings = {
      theme = "${cfg.theme}_nobg";
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        bufferline = "always";
        soft-wrap.enable = true;
        true-color = true;
        rulers = [ 80 ];
        file-picker.hidden = false;
      };
      keys.select = {
        p.s = ":pipe sort";
        p.w = ":pipe wrap";
        p.c = ":pipe cwrap";
      };
    };
  };

  nixConfig = {
    languages.language-server = {
      nixd.command = "${pkgs.nixd}/bin/nixd";
      nil.command = "${pkgs.nil}/bin/nil";
    };
    languages.language = [
      {
        name = "nix";
        formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        auto-format = true;
        language-servers = [
          "nixd"
          {
            name = "nil";
            except-features = [ "completion" ];
          }
        ];
      }
    ];
  };

  goConfig = {
    languages.language-server = {
      gopls.command = "${pkgs.gopls}/bin/gopls";
      protols.command = "${pkgs.protols}/bin/protols";
    };
    languages.language = [
      {
        name = "protobuf";
        formatter.command = "${pkgs.protols}/bin/protols";
        auto-format = true;
        language-servers = [ "protols" ];
      }
    ];
  };

  webConfig =
    let
      mkTsLsp =
        {
          name,
          parser ? name,
          auto-format ? true,
        }:
        {
          inherit name auto-format;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [
              "--parser"
              parser
            ];
          };
          language-servers = [ "typescript-language-server" ];
        };
    in
    {
      languages.language-server.typescript-language-server.command = "${pkgs-tls-501.typescript-language-server}/bin/typescript-language-server";
      languages.language = [
        (mkTsLsp { name = "typescript"; })
        (mkTsLsp {
          name = "javascript";
          parser = "typescript";
        })
        (mkTsLsp {
          name = "tsx";
          parser = "typescript";
        })
        (mkTsLsp {
          name = "jsx";
          parser = "typescript";
        })
        (mkTsLsp { name = "html"; })
        (mkTsLsp { name = "css"; })
        (mkTsLsp { name = "json"; })
        (mkTsLsp {
          name = "markdown";
          auto-format = false;
        })
      ];
    };

  rustConfig = {
    languages.language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    languages.language = [
      {
        name = "rust";
        formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
        formatter.args = [
          "--edition"
          "2021"
        ];
        auto-format = true;
      }
    ];
  };

  cConfig = {
    languages.language-server.clangd.command = "${pkgs.stdenv.cc.cc}/bin/clangd";
    languages.language = [
      {
        name = "c";
        formatter.command = "${pkgs.stdenv.cc.cc}/bin/clang-format";
        auto-format = true;
      }
    ];
  };

  pythonConfig = {
    languages.language-server.pylsp = {
      command = "${
        pkgs.python3.withPackages (
          ps: with ps; [
            python-lsp-server
            python-lsp-ruff
          ]
        )
      }/bin/pylsp";
      plugins.ruff.enabled = true;
      plugins.ruff.lineLength = cfg.lineLength;
    };
    languages.language = [
      {
        name = "python";
        auto-format = true;
      }
    ];
  };

in
{
  options.programs.computerdane-helix = {

    enable = mkEnableOption "computerdane's cracked Helix config";

    package = mkOption {
      description = "Helix package to use";
      type = package;
      default = pkgs.helix;
    };

    defaultEditor = mkEnableOption "Helix as the default editor";

    theme = mkOption {
      description = "Name of the Helix theme to use";
      type = str;
      default = "catppuccin_mocha";
    };

    languages = {
      nix.enable = mkEnableOption "Nix LSP support";
      go.enable = mkEnableOption "Golang LSP support";
      web.enable = mkEnableOption "TypeScript, JavaScript, HTML, CSS, JSON, and Markdown LSP support";
      rust.enable = mkEnableOption "Rust LSP support";
      c.enable = mkEnableOption "C LSP support";
      python.enable = mkEnableOption "Python LSP support";
    };

    lineLength = mkOption {
      description = "Sets line length settings for wrapping shortcuts and some formatters";
      type = int;
      default = 80;
    };

  };

  config = mkIf cfg.enable {

    programs.helix = mkMerge (flatten [
      baseConfig
      (with cfg.languages; [
        (mkIf nix.enable nixConfig)
        (mkIf go.enable goConfig)
        (mkIf web.enable webConfig)
        (mkIf rust.enable rustConfig)
        (mkIf c.enable cConfig)
        (mkIf python.enable pythonConfig)
      ])
    ]);

    home.packages =
      let
        mkWrapCmd =
          name: pfx:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ pkgs.uutils-coreutils ];
            text =
              let
                ll = toString cfg.lineLength;
              in
              ''uutils-fmt -w ${ll} -g ${ll} -p "${pfx}"'';
          };
      in
      mkMerge [
        [ (mkWrapCmd "wrap" "") ]
        (mkIf (cfg.languages.go.enable || cfg.languages.rust.enable) [ (mkWrapCmd "cwrap" "//") ])
        (mkIf cfg.languages.c.enable [ pkgs.lldb_19 ])
      ];

  };
}
