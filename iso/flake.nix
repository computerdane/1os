{
  description = "Minimal NixOS installation with default user and SSH key";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations."1os" =
        with nixpkgs.lib;
        nixosSystem {
          system = "x86_64-linux";
          modules = [
            (
              { pkgs, modulesPath, ... }:
              {
                imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

                users.users.dane = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuxIieYmJTQPyVhQW6Hyt2rzpaQajJwyw/wMdNg5VVY danerieber@gmail.com"
                  ];
                };

                services.openssh = {
                  enable = true;
                  settings = {
                    PermitRootLogin = mkForce "no";
                    PasswordAuthentication = false;
                    KbdInteractiveAuthentication = false;
                    Port = 105;
                  };
                };
              }
            )
          ];
        };
    };
}
