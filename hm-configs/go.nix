{ pkgs, ... }:

{
  home.packages = with pkgs; [
    clang-tools # needed for protols
    go
    gopls
    protobuf
    protols
  ];

  programs.helix = {
    languages.language-server.protols.command = "protols";
    languages.language = [
      {
        name = "protobuf";
        formatter.command = "protols";
        auto-format = true;
        language-servers = [ "protols" ];
      }
    ];
  };
}
