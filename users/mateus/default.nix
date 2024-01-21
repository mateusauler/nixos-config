{ config, pkgs, ... }:

let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.mateus = {
    isNormalUser = true;
    group = "users";
    extraGroups = [
      "disk"
      "input"
      "networkmanager"
      "wheel"
    ] ++ ifTheyExist [
      "docker"
      "libvirtd"
      "vpn"
    ];

    hashedPasswordFile = config.sops.secrets.password-mateus.path;
    shell = pkgs.fish;

    createHome = true;
    home = "/home/mateus";
  };

  sops.secrets.password-mateus = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
