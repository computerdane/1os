{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "hll-arty-calc";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "hll-arty-calc";
    rev = "v${version}";
    hash = "sha256-TDTc1Rv/nx2AkDI1pfTdSAkLBj5wXvd9Lt7+HPNzvAk=";
  };

  vendorHash = null;
  ldflags = [ "-X main.Version=${version}" ];
}
