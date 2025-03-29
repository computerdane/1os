{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with types;

let
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
      languages.language-server.typescript-language-server.command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
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

  pythonConfig = {
    languages.language-server = {
      pyright = {
        command = "${pkgs.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
      };
      ruff-lsp = {
        command = "${pkgs.ruff-lsp}/bin/ruff-lsp";
        config = {
          documentFormatting = true;
          settings.run = "onSave";
        };
      };
    };
    languages.language = [
      {
        name = "python";
        auto-format = true;
        language-servers = [
          {
            name = "pyright";
            except-features = [
              "format"
              "diagnostics"
            ];
          }
          {
            name = "ruff-lsp";
            only-features = [
              "format"
              "diagnostics"
            ];
          }
        ];
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
      default = "dracula";
    };

    languages = {
      nix.enable = mkEnableOption "Nix LSP support";
      go.enable = mkEnableOption "Golang LSP support";
      web.enable = mkEnableOption "TypeScript, JavaScript, HTML, CSS, JSON, and Markdown LSP support";
      python.enable = mkEnableOption "Python LSP support";
    };

  };

  config = mkIf cfg.enable {

    programs.helix = mkMerge (flatten [
      baseConfig
      (with cfg.languages; [
        (mkIf nix.enable nixConfig)
        (mkIf go.enable goConfig)
        (mkIf web.enable webConfig)
        (mkIf python.enable pythonConfig)
      ])
    ]);

    home.packages = mkIf cfg.languages.go.enable [
      (pkgs.writeShellApplication {
        name = "gowrap";
        runtimeInputs = [ pkgs.uutils-coreutils ];
        text = ''fmt -w 80 -g 80 -p //'';
      })
    ];

  };
}
