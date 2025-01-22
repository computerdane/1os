{ pkgs, ... }:

{
  oneos = {
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
    virtualisation.enable = true;
  };

  environment.systemPackages = [ pkgs.godot_4 ];
}
