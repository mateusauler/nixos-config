{ lib, ... }:

module-names: extra:
let
  join-modules =
    acc: mod:
    let
      path = (lib.strings.splitString "." mod) ++ [ "enable" ];
    in
    lib.recursiveUpdate acc (lib.attrsets.setAttrByPath path (lib.mkDefault true));
in
(builtins.foldl' join-modules extra module-names)
