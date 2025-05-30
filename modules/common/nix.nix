{ config, lib, ... }:

let
  inherit (lib) mkDefault;
in
{
  nix = {
    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      auto-allocate-uids = true;
      auto-optimise-store = mkDefault true;
      keep-outputs = mkDefault true;
      keep-derivations = mkDefault true;
      trusted-users = [ "root" ] ++ config.enabledUsers;
      use-xdg-base-directories = mkDefault true;
      warn-dirty = mkDefault false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
