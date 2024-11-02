{ config, lib, ... }:

with lib;
with types;

{
  options.oneos.domains = {
    domains = mkOption {
      type = listOf str;
      default = [
        "nf6.sh"
        "knightf6.com"
      ];
    };
    default = mkOption {
      type = str;
      default = elemAt config.oneos.domains.domains 0;
    };
  };
}
