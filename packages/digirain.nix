{
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "digirain";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "digirain";
    rev = "main";
    hash = "sha256-WnE3vsQy8oMb7M6Il5Fui/JfVAZ+eBdw4752yeZxbMc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-5ZUQwidL1+jhONbxYlrtS/woJYn3PnVbBsYA1WH7+48=";
}
