{ config, lib, ... }:

let
  cfg = config.home.editable-file;
in
{
  options.home.editable-file = lib.mkOption {
    description = "Same as the options for `home.file.<name>`";
    type = lib.types.attrs;
    default = { };
  };

  config.home.file = lib.mapAttrs' (
    name: value:
    lib.nameValuePair "${name}_init" (
      value
      // {
        # Taken from https://github.com/nix-community/home-manager/issues/3090#issuecomment-2010891733
        # Creates a file with specific permissions
        onChange =
          let
            dir = config.home.homeDirectory;
          in
          ''
            rm -f "${dir}/${name}"
            cp "${dir}/${name}_init" "${dir}/${name}"
            chmod a+rw "${dir}/${name}"
          '';
      }
    )
  ) cfg;
}
