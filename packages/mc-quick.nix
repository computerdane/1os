{
  bash,
  buildGoModule,
  coreutils,
  fetchFromGitHub,
  javaPackage ? temurin-jre-bin,
  lib,
  makeWrapper,
  rsync,
  temurin-jre-bin,
  unzip,
}:

buildGoModule rec {
  pname = "mc-quick";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "mc-quick";
    rev = "v${version}";
    hash = "sha256-CwtjwFvPfsNzTWeVu7OTimfNBtRxPeZ7393nq69esZo=";
  };

  vendorHash = "sha256-DHDfcaLOGEOmlbVTA8hmOi6Gnhek7L0QZ7J3im0YbSI=";

  ldflags = [ "-X main.Version=v${version}" ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/mc-quick \
      --set PATH ${
        lib.makeBinPath [
          bash
          coreutils
          javaPackage
          rsync
          unzip
        ]
      }
  '';
}
