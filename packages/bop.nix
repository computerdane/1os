{
  mpv,
  netcat,
  writeShellApplication,
}:

writeShellApplication {
  name = "bop";
  runtimeInputs = [
    mpv
    netcat
  ];
  text = ''
    echo "$*" | nc nf6.sh 8085 -w1 | xargs -d '\n' -n 1000 mpv --volume=50
  '';
}
