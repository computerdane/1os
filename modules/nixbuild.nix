{ config, lib, ... }:

let
  cfg = config.oneos.nixbuild;
in
{
  options.oneos.nixbuild.enable = lib.mkEnableOption "enable nixbuild.net as a remote builder";

  config = lib.mkIf cfg.enable {

    sops.secrets.nixbuild-key = {
      mode = "0440";
      owner = config.users.users.nobody.name;
      group = config.users.groups.nixbuild.name;
    };

    users.groups.nixbuild = { };
    users.users.dane.extraGroups = [ "nixbuild" ];

    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile ${config.sops.secrets.nixbuild-key.path}
    '';

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          system = "x86_64-linux";
          maxJobs = 100;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
        }
      ];
      extraOptions = ''
        builders-use-substitutes = true
      '';
      settings.substituters = [ "ssh://eu.nixbuild.net" ];
      settings.trusted-public-keys = [
        "nixbuild.net/NMLPEQ-1:KJc+6kHLrauNsKeZOPKLWg9kD0oTWsbWeNUkTrTp6V8="
      ];
    };

  };
}
