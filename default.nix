{
  onix ? import <onix> { },
}:

# let
#   fetchFromGitHub =
#     {
#       owner,
#       repo,
#       rev,
#       sha256,
#     }:
#     builtins.fetchTarball {
#       url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
#       inherit sha256;
#     };

#   onix = import (fetchFromGitHub {
#     owner = "computerdane";
#     repo = "onix";
#     rev = "d0d5cea5d97fd21c49f95a114b7a6e03da44b7ca";
#     sha256 = "1alb1ck41k2w4pl4d27p93a4sszkkw6cbzvqix3601h99fgrsrqk";
#     # sha256 = lib.fakeSha256;
#   }) { };

#   sops = import "${
#     fetchFromGitHub {
#       owner = "Mic92";
#       repo = "sops-nix";
#       rev = "1770be8ad89e41f1ed5a60ce628dd10877cb3609";
#       sha256 = "1fh3mmhkv440ad5m14xdc2154pjx7v76d2gz9kinfvpp9zpslimg";
#     }
#   }/modules/sops";
# in

(onix.init {
  nixpkgs = <nixpkgs>;
  flake = false;
  src = ./.;
  extraModules = [
    <sops-nix/modules/sops>
  ];
  nixpkgsConfig.allowUnfree = true;
})
