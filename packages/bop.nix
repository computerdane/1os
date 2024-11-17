{
  bat,
  mpv,
  netcat,
  writeShellApplication,
}:

writeShellApplication {
  name = "bop";
  runtimeInputs = [
    bat
    mpv
    netcat
  ];
  text = ''
    if [ "$1" == "-l" ]; then
      echo "-s" | nc nf6.sh 8085 -w1 | bat
      exit 0
    fi
      echo "$*" | tr -d "-" | nc nf6.sh 8085 -w1 | xargs -d '\n' -n 1000 mpv --volume=50
  '';
}
