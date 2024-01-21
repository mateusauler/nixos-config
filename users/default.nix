{ lib, ... }:

{
  options.enabledUsers = lib.mkOption {
    description = "Usernames of users to enable";
    default = [ ];
  };

  imports = [
    ./mateus
  ];
}
