{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.change-wallpaper;
  pics-dir = config.xdg.userDirs.pictures;
  wall-dir = "${pics-dir}/wall";
in {
  options.modules.change-wallpaper = {
	  enable = lib.mkEnableOption "change-wallpaper";
	  command = lib.mkOption {
	    type = lib.types.nullOr lib.types.str;
	    default = null;
	  };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
    let
      change-wallpaper = let
        dest = "${pics-dir}/wallpaper";
      in pkgs.writeShellScriptBin "chw" ''
        file=$(find ${wall-dir} -type f | shuf | ${pkgs.nsxiv}/bin/nsxiv -oiqt | head -n 1)
        [ ! -z $file ] && ln -sf $file ${dest}
        ${if cfg.command != null then "${cfg.command} ${dest}" else ""}
      '';
    in
    [ change-wallpaper ];

    xdg.desktopEntries.chw = {
      name = "Change Wallpaper";
      icon = "preferences-desktop-wallpaper";
      exec = "chw";
      terminal = false;
      categories = [ "Application" ];
    };
  };
}
