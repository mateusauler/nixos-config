{ pkgs, config, username, ... }:

{
  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;


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
