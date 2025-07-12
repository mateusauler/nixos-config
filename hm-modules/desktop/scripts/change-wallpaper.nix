{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.change-wallpaper;
  pics-dir = config.xdg.userDirs.pictures;
  wall-dir = "${pics-dir}/wall";
  dest = "${pics-dir}/wallpaper";
  set-wallpaper-command = lib.strings.optionalString (cfg.command != null) "${cfg.command} ${dest}";
in
{
  options.modules.change-wallpaper = {
    enable = lib.mkEnableOption "change-wallpaper";
    command = lib.mkOption { type = with lib.types; nullOr str; };
    daemon = lib.mkOption { type = with lib.types; nullOr str; };
  };

  config = lib.mkIf (cfg.enable && !config.stylix.enable) {
    home = {
      activation = {
        clone-wallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          pkgs.lib.cloneRepo {
            path = wall-dir;
            url = "https://github.com/mateusauler/wallpapers";
          }
        );
      };

      packages =
        let
          find = "${lib.getExe pkgs.findutils}";
          head = "${pkgs.coreutils}/bin/head";
          nsxiv = "${pkgs.nsxiv}/bin/nsxiv";
          sort = "${pkgs.coreutils}/bin/sort";
          change-wallpaper = pkgs.writeShellScriptBin "chw" ''
            file=$(${find} ${wall-dir} -type f | ${sort} | ${nsxiv} -oiqt | ${head} -n 1)
            [ ! -z $file ] && ln -sf $file ${dest}
            ${set-wallpaper-command}
          '';
        in
        [ change-wallpaper ];
    };

    modules.desktop.autostart = cfg.daemon;

    xdg.desktopEntries.chw = {
      name = "Change Wallpaper";
      icon = "preferences-desktop-wallpaper";
      exec = "chw";
      terminal = false;
      categories = [ "Application" ];
    };
  };
}
