{ custom, lib, ... }:

let
  inherit (lib) mkDefault;
  inherit (custom) username;
in
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
      auto-allocate-uids = true;
      auto-optimise-store = mkDefault true;
      keep-outputs = mkDefault true;
      keep-derivations = mkDefault true;
      trusted-users = [ "root" username ];
      use-xdg-base-directories = mkDefault true;
      warn-dirty = mkDefault false;
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 7d";
    };
  };
}
