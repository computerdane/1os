{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "bop";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "bop";
    rev = version;
    hash = "sha256-iiVKVSDaWrv/suQXBWJ02PKmT5uVyXE3y7WDFfg7Sg0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-/73Q/iMvMdgtdL+bmVIzaedEvq80S1PRyAzZgW7TKAQ=";
}
