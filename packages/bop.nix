{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bop";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "bop";
    rev = version;
    hash = "sha256-aOkfkmK+l3WoamxCd0DO5jCu0AwTrUXGlbYvLd3Ykaw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-oyJdkQ3RDekPWVmjyJhXX+fBLnnP1mleZ/b8gHajLWA=";
}
