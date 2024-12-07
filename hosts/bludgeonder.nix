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

  sops.secrets.nf6-api-tls-priv-key = {
    owner = "nf6_api";
    group = "nf6_api";
  };

  sops.secrets.nf6-api-tls-ca-priv-key = {
    owner = "nf6_api";
    group = "nf6_api";
  };

  sops.secrets.nf6-vip-tls-priv-key = { };

  services.nf6 = {
    enable = true;
    openFirewall = true;
    settings = {
      account-prefix6-len = 68;
      db-url = "dbname=nf6";
      global-prefix6 = "2600:1700:591:3b3d::/64";
      tls-ca-cert-path = ../static/nf6-ca.crt;
      tls-ca-priv-key-path = config.sops.secrets.nf6-api-tls-ca-priv-key.path;
      tls-cert-path = ../static/nf6-api.crt;
      tls-priv-key-path = config.sops.secrets.nf6-api-tls-priv-key.path;
      vip-tls-pub-key-path = ../static/nf6-vip.pub;
      vip-wg-endpoint = "nf6.sh:51820";
      vip-wg-pub-key = "LZRMjOX+Kk2iXWR5EHsf208AG4VVf0/ZOT56vAQ2iUE=";
    };
    vipSettings = {
      api-tls-pub-key-path = ../static/nf6-api.pub;
      tls-cert-path = ../static/nf6-vip.crt;
      tls-priv-key-path = config.sops.secrets.nf6-vip-tls-priv-key.path;
      wg-device-name = "wgnf6";
      wg-priv-key-path = config.sops.secrets.gateway-wireguard-nf6-key.path;
    };
  };

  services.syncplay.enable = true;
  networking.firewall.allowedTCPPorts = [ 8999 ];
  networking.firewall.allowedUDPPorts = [ 8999 ];

  # sops.secrets.postgres-nf6_api-password-db = {
  #   owner = "postgres";
  #   group = "postgres";
  # };
  # sops.secrets.postgres-nf6_git-password-db = {
  #   owner = "postgres";
  #   group = "postgres";
  # };

  # sops.secrets.postgres-nf6_api-password-api = with config.services.nf6-api; {
  #   owner = user;
  #   inherit group;
  # };
  # sops.secrets.postgres-nf6_git-password-git = with config.services.nf6-git; {
  #   owner = user;
  #   inherit group;
  # };

  # services = {
  #   nf6-api = {
  #     enable = true;
  #     openFirewall = true;
  #     postgresPasswordFile = config.sops.secrets.postgres-nf6_api-password-api.path;
  #   };
  #   nf6-db = {
  #     enable = true;
  #     apiUserPasswordFile = config.sops.secrets.postgres-nf6_api-password-db.path;
  #     gitUserPasswordFile = config.sops.secrets.postgres-nf6_git-password-db.path;
  #   };
  #   nf6-git = {
  #     enable = true;
  #     postgresPasswordFile = config.sops.secrets.postgres-nf6_git-password-git.path;
  #   };
  # };
}
