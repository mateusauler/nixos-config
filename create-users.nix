{ pkgs, config, username, ... }:

{
  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;

  services.syncthing = {
    user = "${username}";
    dataDir = "/home/${username}/Sync";
    configDir = "/home/${username}/.config/syncthing";
  };

  users.users = {
    ${username} = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "input" ];
      initialPassword = "a";
      createHome = true;
      home = "/home/${username}";
    };
    root.initialPassword = "a";
  };
}
