{ lib, pkgs, ... }:

{
  options.enabledUsers = lib.mkOption {
    description = "Usernames of users to enable";
    default = [ ];
  };

  imports = [ ./mateus ];

  config.users = {
    mutableUsers = lib.mkDefault false;
    users.root = {
      hashedPassword = lib.mkDefault "!"; # Disable root password login
      shell = pkgs.fish;
    };
  };
}
