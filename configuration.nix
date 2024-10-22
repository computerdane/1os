{ pkgs, ... }:

{
  programs.fish.enable = true;

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
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuxIieYmJTQPyVhQW6Hyt2rzpaQajJwyw/wMdNg5VVY danerieber@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILygTablfeGg4QW8UUk7fMJ7Otrnafkb5n4NEbfeMwzt dane@fishtank"
    ];
    shell = pkgs.fish;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "dane" ];
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}
