{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.virtualisation;
in
{
  options.oneos.virtualisation.enable = lib.mkEnableOption "virtualisation";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.spice-gtk ];
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    users.users.dane.extraGroups = [
      "libvirtd"
      "kvm"
    ];
    networking.nftables.enable = lib.mkForce false; # libvirt does not work well with nftables
  };
}
