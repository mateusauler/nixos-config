{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.protonvpn;
in
{
  options.modules.protonvpn.enable = lib.mkEnableOption "ProtonVPN";

  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/307462#issuecomment-2750133149
    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = [ pkgs.protonvpn-gui ];
  };
}
