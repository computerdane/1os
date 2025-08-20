{
  lib,
  makeWrapper,
  nushell,
  stdenv,
  tmux,
  xplr,
}:

stdenv.mkDerivation {
  pname = "computerdane-ide";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share $out/bin
    cp -r $src/* $out/share/

    makeWrapper $out/share/ide.nu $out/bin/ide \
      --prefix PATH : ${
        lib.makeBinPath [
          nushell
          tmux
          xplr
        ]
      }
  '';
}
