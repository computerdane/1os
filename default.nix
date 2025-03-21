{
  nixpkgs,
}:

let
  fetchFromGitHub =
    {
      owner,
      repo,
      rev,
      sha256,
    }:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };

  onix = import (fetchFromGitHub {
    owner = "computerdane";
    repo = "onix";
    rev = "d4a040249e28c2cf9ea6afef3d5b41273d27e10d";
    sha256 = "15asq35kkra2lq8i8mf8hv3nyzfdp16sahlpsyhd63phd5gxbyfc";
    # sha256 = nixpkgs.lib.fakeSha256;
  }) { inherit nixpkgs; };

  sops = import "${
    fetchFromGitHub {
      owner = "Mic92";
      repo = "sops-nix";
      rev = "1770be8ad89e41f1ed5a60ce628dd10877cb3609";
      sha256 = "1fh3mmhkv440ad5m14xdc2154pjx7v76d2gz9kinfvpp9zpslimg";
    }
  }/modules/sops";
in

(onix.init {
  src = ./.;
  extraModules = [ sops ];
})
