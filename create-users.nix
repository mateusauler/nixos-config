{ pkgs, config, usernames, ... }:

{
  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;

  users.users =
  let
    generateUser = username: { 
      name = username;
      value = {
        isNormalUser = true;
        group = "users";
        extraGroups = [ "wheel" ];
        initialPassword = "a";
        createHome = true;
        home = "/home/${username}";
      };
    };
  in
    builtins.listToAttrs(map generateUser usernames) // { root.initialPassword = "a"; };
}
