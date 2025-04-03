{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bop";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "bop";
    rev = version;
    hash = "sha256-BXwpKbGCUCsH84eqbV7mCjfMquBfOk6dyvS9cuLklYg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-WrAg6CUtP3tzNbYeeDBo/DbSaHLhWI2fVZAWMNnFR7E=";
}
