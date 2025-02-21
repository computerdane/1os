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
    rev = "2fa1fbbb052372cc2407ce1b04e0f0143f5f38df";
    hash = "sha256-xBKReol0E4dLhpx3+ixiqQfwxv8JLIRkvjmJZrdnN2s=";
  };

  vendorHash = "sha256-z6jg7cHcgvF7Zte8f7ior3ArckUCaGkg7s1G1i6NsHI=";

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
