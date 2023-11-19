{ lib, ... }:

color: alpha:
let
  colorsNum = lib.colorToIntList color;
  colorsB10 = builtins.map toString colorsNum;
  colorsStr = builtins.concatStringsSep "," colorsB10;
in
"rgba(" + colorsStr + ",${toString alpha})"
