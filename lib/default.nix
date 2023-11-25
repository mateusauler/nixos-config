{ lib, pkgs, ... }@args:

{
  readDirNames       = import ./read-dir-names.nix        args;
  getUsers           = import ./get-users.nix             args;
  mkNixosSystem      = import ./mk-nixos-system.nix       args;
  cloneRepo          = import ./clone-repo.nix            args;
  enableModules      = import ./enable-modules.nix        args;
  mkTrueEnableOption = import ./mk-true-enable-option.nix args;
  fromHex            = import ./from-hex.nix              args;
  colorToIntList     = import ./color-to-int-list.nix     args;
  colorToRgba        = import ./color-to-rgba.nix         args;
}
