{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pyright
    python312
    ruff
    ruff-lsp
  ];

  programs.helix = {
    languages.language-server = {
      pyright = {
        command = "pyright-langserver";
        args = [ "--stdio" ];
      };
      ruff-lsp = {
        command = "ruff-lsp";
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
}
