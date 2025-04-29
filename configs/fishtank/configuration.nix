{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  oneos = {
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    mount-9p.enable = true;
    nixbuild.enable = true;
    protonvpn.enable = true;
  };

  specialisation.amdvlk.configuration = {
    oneos.gpu-amd.amdvlk = true;
  };

  environment.systemPackages = with pkgs; [
    godot_4
    heroic
    kdePackages.kdenlive
    stress-ng
  ];
}
