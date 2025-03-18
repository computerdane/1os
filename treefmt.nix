{ ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.prettier = {
    enable = true;
    excludes = [
      "secrets.yaml"
      ".sops.yaml"
    ];
  };
  programs.shellcheck.enable = true;
}
