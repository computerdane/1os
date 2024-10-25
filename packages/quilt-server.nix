{
  pkgs,
  writeShellApplication,
  fetchurl,
  installerVersion ? "0.9.2",
  hash ? "sha256-w60+I+7oYOUYXFlOfLKA5Pq+fnZqg5RTgdmpnGSFXFs=",
  minecraftVersion ? "1.21.1",
  javaPackage ? pkgs.temurin-jre-bin,
  eula ? true,
}:

let
  installerJar = fetchurl {
    url = "https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/${installerVersion}/quilt-installer-${installerVersion}.jar";
    inherit hash;
  };
in
writeShellApplication {
  name = "quilt-server";
  runtimeInputs = [ javaPackage ];
  text = ''
    STATE_DIR=$1

    mkdir -p "$STATE_DIR"
    cd "$STATE_DIR"
    java -jar ${installerJar} install server ${minecraftVersion} --download-server
    cd server
    ${if eula then "echo eula=true > eula.txt" else ""}
    java -jar quilt-server-launch.jar nogui
  '';
}
