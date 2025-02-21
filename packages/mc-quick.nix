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
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "mc-quick";
    rev = "v${version}";
    hash = "sha256-cLRWKJibcn/3jCuG5r356yzoQlw+tdRjhjgbu6jZYT8=";
  };

  vendorHash = "sha256-b5w+Gy9tUsYOf0usoZXDOTiso6S8UntO735N0hMSGYY=";

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
