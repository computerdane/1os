{
  acme = import ./acme.nix;
  auto-update = import ./auto-update.nix;
  chatwick = import ./chatwick.nix;
  desktop = import ./desktop.nix;
  domains = import ./domains.nix;
  dynamic-dns = import ./dynamic-dns.nix;
  extra-users = import ./extra-users.nix;
  factorio-server = import ./factorio-server.nix;
  file-share = import ./file-share.nix;
  gaming = import ./gaming.nix;
  gateway = import ./gateway.nix;
  gatewayv2 = import ./gatewayv2.nix;
  gpu-amd = import ./gpu-amd.nix;
  gpu-nvidia = import ./gpu-nvidia.nix;
  jellyfin = import ./jellyfin.nix;
  litellm = import ./litellm.nix;
  livestream-server = import ./livestream-server.nix;
  mc-quick = import ./mc-quick.nix;
  mount-9p = import ./mount-9p.nix;
  nginx = import ./nginx.nix;
  nixbuild = import ./nixbuild.nix;
  protonvpn = import ./protonvpn.nix;
  vault = import ./vault.nix;
  vintagestory-server = import ./vintagestory-server.nix;
  virtualisation = import ./virtualisation.nix;
}
