{ pkgs, ... }:

{
  oneos = {
    auto-update.pull = true;
    desktop.enable = true;
    dynamic-dns.enable = true;
    gaming.enable = true;
  };

  users.users.ethan = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
}
