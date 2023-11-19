{ lib, ... }:

str:
let
  hexChars = lib.strings.stringToCharacters "0123456789ABCDEF";

  toInt = c: lib.lists.findFirstIndex (x: x == c) (throw "invalid hex digit: ${c}") hexChars;
  accumulate = a: c: a * 16 + toInt c;

  strU = lib.strings.toUpper str;
  chars = lib.strings.stringToCharacters strU;
in
builtins.foldl' accumulate 0 chars
