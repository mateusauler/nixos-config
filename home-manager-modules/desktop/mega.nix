{ config, lib, pkgs, ... }:

let
  cfg = config.modules.mega;
in
{
  options.modules.mega = {
    enable = lib.mkEnableOption "MEGA cmd";
    syncdir = lib.mkOption { default = null; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      megacmd
    ];

    modules.hyprland.extraAutostart.megacmd = "mega-cmd-server";

    modules.mega.syncdir = lib.mkDefault "${config.home.homeDirectory}/mega";

    # TODO: Add auto authentication & setup
    # home.activation."mega-sync-setup" =
    #   let
    #     inherit (config.modules.mega) syncdir;
    #     mega-sync = "${pkgs.megacmd}/bin/mega-sync";
    #     mega-session = "${pkgs.megacmd}/bin/mega-session";
    #   in
    #   lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #     if ${mega-sync} | grep -qv "${syncdir}" && ${mega-session} > /dev/null; then
    #       $DRY_RUN_CMD ${mega-sync} "${syncdir}" /
    #     fi
    #   '';
  };
}
