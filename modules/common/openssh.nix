{ pkgs, options, config, lib, ... }:

let
  inherit (lib) mkDefault;
  cfg = config.modules.openssh;
in {
  options.modules.openssh.enable = lib.mkEnableOption "openssh";

  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
      sshguard = {
        enable = true;
        attack_threshold = 15;
      };
    };
    security.rtkit.enable = mkDefault true;
  };
}
