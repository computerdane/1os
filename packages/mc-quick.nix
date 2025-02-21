{
  bash,
  buildGoModule,
  coreutils,
  fabric-installer,
  fetchFromGitHub,
  javaPackage ? temurin-jre-bin,
  lib,
  makeWrapper,
  rsync,
  temurin-jre-bin,
  unzip,
}:

buildGoModule {
  pname = "mc-quick";
  version = "test";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "mc-quick";
    rev = "v1.0.0";
    hash = "sha256-r8XPbxYRDVfQqu1hUs8Pwx6ChTtebt2EFmlv9U7fcHk=";
  };

  vendorHash = "sha256-fZ6Z8tI9RQTIP7CsD9Qez7ssSSigDb3UU4NK8Cezq1E=";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/mc-quick \
      --set PATH ${
        lib.makeBinPath [
          bash
          coreutils
          fabric-installer
          javaPackage
          rsync
          unzip
        ]
      }
  '';
}
