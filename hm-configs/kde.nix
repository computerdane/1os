{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;
    workspace.wallpaperSlideShow.path = "${
      pkgs.fetchFromGitHub {
        owner = "computerdane";
        repo = "wallpapers";
        rev = "main";
        hash = "sha256-LSnUOGbQoaVyct1QuE59J6vTsnYzm+WaH7xyi8gcXTw=";
      }
    }/rivals";
  };
}
