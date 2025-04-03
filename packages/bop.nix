{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bop";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "bop";
    rev = version;
    hash = "sha256-jaUmZL9cPUlwDqNE8pXPNBYIKRhRYv/J43hPvdt9n8s=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-GM73f5NYZsjdNTJZZiHSv6Kmjr3MkB6GF/BidIHcwKE=";
}
