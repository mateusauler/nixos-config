{ config, pkgs, ... }:

{
  users.users.mateus = {
    isNormalUser = true;
    group = "users";
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "disk"
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
