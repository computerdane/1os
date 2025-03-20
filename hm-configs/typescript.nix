{ pkgs, ... }:

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
        command = "prettier";
        args = [
          "--parser"
          parser
        ];
      };
      language-servers = [ "typescript-language-server" ];
    };
in
{
  home.packages =
    (with pkgs.unstable; [ bun ])
    ++ (
      with pkgs;
      [ nodejs_22 ]
      ++ (with nodePackages; [
        prettier
        typescript-language-server
      ])
    );

  programs.helix.languages.language = [
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
}
