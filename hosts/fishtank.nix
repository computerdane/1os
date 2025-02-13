{ pkgs, ... }:

{
  oneos = {
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
    gpu-amd = {
      enable = true;
      # useWeirdLibs = true;
    };
    # virtualisation.enable = true;
  };

  environment.systemPackages = with pkgs; [
    godot_4
    heroic
  ];
}
