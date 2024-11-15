{ ... }:

{
  oneos = {
    auto-update = {
      pull = true;
      push = true;
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
    nf6-api.enable = true;
    nf6-db.enable = true;
    nf6-git.enable = true;
    vault.enable = true;
  };
}
