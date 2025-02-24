{ pkgs, ... }:

{
  oneos = {
    # auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd.enable = true;
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
