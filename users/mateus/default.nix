{
  config,
  lib,
  pkgs,
  ...
}:

let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  username = "mateus";
  home = config.users.users.${username}.home;
in
lib.mkIf (builtins.elem username config.enabledUsers) {
  users.users.${username} = {
    isNormalUser = true;
    group = "users";
    extraGroups =
      [
        "disk"
        "input"
        "wheel"
      ]
      ++ ifTheyExist [
        "docker"
        "libvirtd"
        "networkmanager"
        "syncthing"
        "vpn"
        "wireshark"
      ];

    hashedPasswordFile = lib.mkDefault config.sops.secrets."password-${username}".path;
    shell = pkgs.fish;

    createHome = true;
    home = "/home/${username}";

    openssh.authorizedKeys.keys = [
      # Phone
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP56bdfAtV1Lng/GCo182w6goeKJsokYft15f5S3rpRg"
      (builtins.readFile ./id_ed25519.pub)
    ];
  };

  services.syncthing = lib.mkIf (!config.modules.server.enable) {
    user = username;
    dataDir = home;
  };

  sops.secrets = {
    "password-${username}" = {
      sopsFile = ./password;
      format = "binary";
      neededForUsers = true;
    };
    "keys.txt" = lib.mkIf (!config.modules.server.enable) {
      sopsFile = ./keys.txt;
      format = "binary";
      owner = username;
      path = "${home}/.config/sops/age/keys.txt";
    };
  };
}
