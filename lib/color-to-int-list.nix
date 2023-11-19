{ lib, ... }:

color:
let
  colorsChr = lib.strings.stringToCharacters color;
  colorsSep = lib.strings.concatImapStrings (pos: c: if (lib.trivial.mod pos 2 == 0) then c + " " else c) colorsChr;
  colorsHexDirty = lib.strings.splitString " " colorsSep;
  colorsHex = lib.lists.remove "" colorsHexDirty;
in
builtins.map lib.fromHex colorsHex
