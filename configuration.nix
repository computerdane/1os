{ pkgs, ... }:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  environment.systemPackages = with pkgs; [
    home-manager
    sops
    age
    ssh-to-age
    waypipe
    wireguard-tools
    iwgtk
  ];

  programs.fish.enable = true;

  systemd.network.enable = true;
  networking = {
    useNetworkd = true;
    nftables.enable = true;
    wireless.iwd.enable = true;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.dane = {
    isNormalUser = true;
    initialPassword = "abc123";
    extraGroups = [
      "wheel"
      "network"
      "bop"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuxIieYmJTQPyVhQW6Hyt2rzpaQajJwyw/wMdNg5VVY" # laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILygTablfeGg4QW8UUk7fMJ7Otrnafkb5n4NEbfeMwzt" # fishtank/limbo
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeXM/afFCGyO69zC7+Dhw6jcY5y7vnaAIXkI5RTY/Pu" # op12
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLvONY5rvgbkp9ytyCuqFgU5u+h91Eol72URbGFhM0i" # eefan
    ];
    shell = pkgs.nushell;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "dane" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.registry = import ./registry.nix;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
}
