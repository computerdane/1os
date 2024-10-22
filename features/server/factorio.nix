{ pkgs, ... }:

let
  factorio-headless-latest = pkgs.factorio-headless.override {
    versionsJson = pkgs.writeText "versions.json" (
      builtins.toJSON {
        x86_64-linux.headless.stable = {
          name = "factorio_headless_x64-2.0.8.tar.xz";
          needsAuth = false;
          sha256 = "sha256-2VlMTVUqPk+WWxiKR3TajIsBD8I92w78Y7HZSBjd4co=";
          tarDirectory = "x64";
          url = "https://www.factorio.com/get-download/2.0.8/headless/linux64";
          version = "2.0.8";
        };
      }
    );
  };
in
{
  services.factorio = {
    enable = true;
    package = factorio-headless-latest;
    openFirewall = true;
    game-password = "sex";
    lan = true;
  };
}
