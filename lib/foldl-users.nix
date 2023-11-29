{ lib, ... }:

config:
{ acc ? { }, fn }:
let
  users =
    lib.filterAttrs
      (_: v: v.isNormalUser)
      config.users.users;
in
lib.foldlAttrs fn acc users
