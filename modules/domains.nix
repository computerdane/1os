{ lib, ... }:

{
  options.oneos.domains =
    with lib;
    with types;
    mkOption {
      type = listOf str;
      default = [
        "knightf6.com"
        "nf6.sh"
      ];
    };
}
