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
    gateway.enable = true;
    vault.enable = true;
  };
}
