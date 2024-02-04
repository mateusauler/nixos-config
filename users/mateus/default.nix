{ config, lib, pkgs, ... }:

let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
lib.mkIf (builtins.elem "mateus" config.enabledUsers)
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

    openssh.authorizedKeys.keys = [ (builtins.readFile ./id_ed25519.pub) ];
  };

  sops.secrets.password-mateus = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
