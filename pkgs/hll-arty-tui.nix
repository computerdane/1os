{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "hll-arty-tui";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "hll-arty-tui";
    rev = "v${version}";
    hash = "sha256-019AzJtP45UIQBvOuPpd2FHfCDUxYPhcX+nauBFkC0c=";
  };

  vendorHash = "sha256-3NehgSR6y64/6VlvS7CcdAcekHTGXOHgWW0Zn3uX8hc=";
}
