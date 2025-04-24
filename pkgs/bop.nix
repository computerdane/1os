{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bop";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "bop";
    rev = version;
    hash = "sha256-VGMeZnzpdQJ2yBhTa+tvGSgp7hvkpp8+v35/FoZPY0A=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-V7yGVF6JOwgNtozoPZzA+77YvVN+6fbdQlMhEDpNhFo=";
}
