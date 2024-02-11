{ config, lib, pkgs, ... }:

let
  ifTheyExist = groups:
    builtins.filter
      (group: builtins.hasAttr
        group
        config.users.groups)
      groups;
  username = "mateus";
in
lib.mkIf (builtins.elem username config.enabledUsers) {
  users.users.${username} = {
    isNormalUser = true;
    group = "users";
    extraGroups = [
      "disk"
      "input"
      "wheel"
    ] ++ ifTheyExist [
      "docker"
      "libvirtd"
      "networkmanager"
      "syncthing"
      "vpn"
    ];

    hashedPasswordFile = lib.mkDefault config.sops.secrets."password-${username}".path;
    shell = pkgs.fish;

    createHome = true;
    home = "/home/${username}";

    openssh.authorizedKeys.keys = [ (builtins.readFile ./id_ed25519.pub) ];
  };

  services.syncthing = let home = config.users.users.${username}.home; in
    {
      enable = lib.mkDefault true;
      openDefaultPorts = true;
      user = username;
      dataDir = home;
    };

  sops.secrets.password-mateus = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
