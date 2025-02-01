{ config, ... }:

{
  oneos = {
    # acme.useStaging = true;
    # ai.enable = true;
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
    chatwick.enable = true;
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

  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/nas/hl/music";
    };
  };
}
