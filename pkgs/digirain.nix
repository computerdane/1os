{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "digirain";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "digirain";
    rev = version;
    hash = "sha256-1fcF1grw73eiulyOYW0cBhyBbY/0UXeNIcwwLWHrnh0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-M50Y+3Q1zp9z+rTW97lXrduF0bWSuP33y7qRFnSmdos=";
}
