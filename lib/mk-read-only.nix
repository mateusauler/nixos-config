{ lib, ... }:

value:
lib.mkOption {
  default = value;
  readOnly = true;
}
