{ pkgs, custom, config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${custom.username}/.config/sops/age/keys.txt";
  };
}
