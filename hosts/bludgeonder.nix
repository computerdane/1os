{ config, ... }:

{
  oneos = {
    # acme.useStaging = true;
    ai.enable = true;
    auto-update = {
      pull = true;
      push = true;
    };
    bop = {
      enable = true;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGut2t5lGOa1UrDfiMedZi93m17SU8CwlT9UvUMRgEHz john@nixos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIPLz8u9B6CEFgUyOtdFTJmkbNA3A9xoKA94UMirGrz" # scott
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICnjmTXWpxkporvlxiJoK/lxccZ1Q1VtLuTVSLvjKNwK" # allie
      ] ++ config.users.users.dane.openssh.authorizedKeys.keys;
    };
    dynamic-dns = {
      enable = true;
      root = true;
      ipv4 = true;
    };
    factorio-server.enable = true;
    file-share.enable = true;
    gateway.enable = true;
    # livestream-server.enable = true;
    vault.enable = true;
  };

  sops.secrets.postgres-nf6_api-password-db = {
    owner = "postgres";
    group = "postgres";
  };
  sops.secrets.postgres-nf6_git-password-db = {
    owner = "postgres";
    group = "postgres";
  };

  sops.secrets.postgres-nf6_api-password-api = with config.services.nf6-api; {
    owner = user;
    inherit group;
  };
  sops.secrets.postgres-nf6_git-password-git = with config.services.nf6-git; {
    owner = user;
    inherit group;
  };

  services = {
    nf6-api = {
      enable = true;
      openFirewall = true;
      postgresPasswordFile = config.sops.secrets.postgres-nf6_api-password-api.path;
    };
    nf6-db = {
      enable = true;
      apiUserPasswordFile = config.sops.secrets.postgres-nf6_api-password-db.path;
      gitUserPasswordFile = config.sops.secrets.postgres-nf6_git-password-db.path;
    };
    nf6-git = {
      enable = true;
      postgresPasswordFile = config.sops.secrets.postgres-nf6_git-password-git.path;
    };
  };
}
