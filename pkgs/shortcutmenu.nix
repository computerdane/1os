{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "shortcutmenu";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "shortcutmenu";
    rev = version;
    hash = "sha256-CjzqSqm1p0qkQY9JdpZGsfq64sRTaAWp0JDhg681jXI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-qNG+19iXmu6+SuSffkCgIN8gu9wSIsR8ipjK2KHffbM=";
}
