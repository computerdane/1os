{ pkgs-1os, ... }:

{
  environment.systemPackages = [ pkgs-1os.quilt-server ];
}
