{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    (writeShellApplication {
      name = "1switch";
      runtimeInputs = [ nixos-rebuild ];
      text = ''
        nixos-rebuild switch -v --impure --flake ".#$(hostname -s)"
      '';
    })
    (writeShellApplication {
      name = "1deploy";
      runtimeInputs = [ nixos-rebuild ];
      text = ''
        nixos-rebuild switch -v --impure --flake ".#$1" --target-host "$2" --use-remote-sudo
      '';
    })
    (writeShellApplication {
      name = "1homeswitch";
      runtimeInputs = [ home-manager ];
      text = ''
        home-manager switch -v --impure --flake ".#$(whoami)@$(hostname -s)"
      '';
    })
    (writeShellApplication {
      name = "1homedeploy";
      runtimeInputs = [ nixos-rebuild ];
      text = ''
        home-manager build -v --impure --flake ".#$1"
        nix-copy-closure --to "$2" result
        ssh -t "$2" "$(readlink result)/activate"
      '';
    })
  ];
}
