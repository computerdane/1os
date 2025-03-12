{
  bash,
  buildGoModule,
  coreutils,
  fetchFromGitHub,
  installShellFiles,
  javaPackage ? temurin-jre-bin,
  lib,
  makeWrapper,
  rsync,
  stdenv,
  temurin-jre-bin,
  unzip,
}:

buildGoModule rec {
  pname = "mc-quick";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "computerdane";
    repo = "mc-quick";
    rev = "v${version}";
    hash = "sha256-JpBJHJSaFYMHVYDmrTpGwROIvVXrPQIZ7pbiIolGUVs=";
  };

  vendorHash = "sha256-xzgNJbuUFL+spUp66CEYz4kreA+UgdV4tyDGVVRlUMc=";

  ldflags = [ "-X main.Version=v${version}" ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mc-quick \
      --fish <($out/bin/mc-quick --fish-completions)
  '';

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
