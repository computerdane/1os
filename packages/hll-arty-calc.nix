{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "hll-arty-calc";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "hll-arty-calc";
    rev = "v${version}";
    hash = "sha256-1otrRs+BlAVwEYXqaeNusn+oAa7xDcXHqgwjFghLp8o=";
  };

  vendorHash = null;
  ldflags = [ "-X main.Version=${version}" ];
}
