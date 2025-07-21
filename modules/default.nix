{
  acme = import ./acme.nix;
  auto-update = import ./auto-update.nix;
  desktop = import ./desktop.nix;
  domains = import ./domains.nix;
  dynamic-dns = import ./dynamic-dns.nix;
  extra-users = import ./extra-users.nix;
  factorio-server = import ./factorio-server.nix;
  fossai = import ./fossai.nix;
  gaming = import ./gaming.nix;
  gatewayv2 = import ./gatewayv2.nix;
  gha-webhook-poc = import ./gha-webhook-poc.nix;
  gpu-amd = import ./gpu-amd.nix;
  gpu-nvidia = import ./gpu-nvidia.nix;
  jellyfin = import ./jellyfin.nix;
  litellm = import ./litellm.nix;
  mc-quick = import ./mc-quick.nix;
  nginx = import ./nginx.nix;
  protonvpn = import ./protonvpn.nix;
  servarr = import ./servarr.nix;
  vault = import ./vault.nix;
  vintagestory-server = import ./vintagestory-server.nix;
  virtualisation = import ./virtualisation.nix;
}
