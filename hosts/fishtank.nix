{ pkgs, ... }:

{
  oneos = {
    acme.enable = true;
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    jellyfin = {
      enable = true;
      subdomain = "watch-beta";
      ipv4 = false;
    };
    # mount-9p.enable = true;
    nginx.enable = true;
    protonvpn.enable = true;
    # virtualisation.enable = true;
  };

  specialisation.amdvlk.configuration = {
    oneos.gpu-amd.useWeirdLibs = true;
  };

  environment.systemPackages = with pkgs; [
    godot_4
    heroic
  ];
}
