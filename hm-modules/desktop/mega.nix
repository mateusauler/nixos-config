{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.mega;
in
{
  options.modules.mega = {
    enable = lib.mkEnableOption "MEGA cmd";
    syncdir = lib.mkOption { default = null; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ megacmd ];

    modules.desktop.autostart = "mega-cmd-server";

    modules.mega.syncdir = lib.mkDefault "${config.home.homeDirectory}/mega";

    home.file.mega-excluded = {
      target = ".megaCmd/excluded";
      text = ''
        .direnv/
        Thumbs.db
        build/
        desktop.ini
        result/
        target/
        ~*
      '';
    };

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
