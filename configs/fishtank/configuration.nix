{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    # acme.enable = true;
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    # extra-users.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    # jellyfin = {
    #   enable = true;
    #   subdomain = "watch-beta";
    # };
    mount-9p.enable = true;
    # nginx.enable = true;
    protonvpn.enable = true;
    # virtualisation.enable = true;
  };

  specialisation.amdvlk.configuration = {
    oneos.gpu-amd.amdvlk = true;
  };

  environment.systemPackages = with pkgs; [
    godot_4
    heroic
    kdenlive
    stress-ng
  ];

  programs.corectrl.enable = true;
  programs.corectrl.gpuOverclock.enable = true;
}
