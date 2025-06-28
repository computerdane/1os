{ callPackage, fetchFromGitHub }:

callPackage "${
  fetchFromGitHub {
    owner = "computerdane";
    repo = "bop-nu";
    rev = "0.1.0";
    hash = "sha256-zRCWPa7eFBAEt3f9Oa1POemPoNbc6NrIC692l78qiG4=";
  }
}/default.nix" { }
