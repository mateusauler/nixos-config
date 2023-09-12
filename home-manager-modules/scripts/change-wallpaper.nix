{ config, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.change-wallpaper;
  pics-dir = config.xdg.userDirs.pictures;
  wall-dir = "${pics-dir}/wall";
  dest = "${pics-dir}/wallpaper";
  set-wallpaper-command = lib.strings.optionalString (cfg.command != null) "${cfg.command} ${dest}";
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.change-wallpaper = {
	  enable = lib.mkEnableOption "change-wallpaper";
	  command = with lib.types; lib.mkOption {
	    type = nullOr str;
	    default = null;
	  };
  };

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        clone-wallpapers = lib.hm.dag.entryAfter ["writeBoundary"] (
          pkgs.lib.cloneRepo {
            path = wall-dir;
            url = "https://github.com/mateusauler/wallpapers";
          }
        );
        set-default-wallpaper =
        let
          default-wallpaper = nix-colors-lib.nixWallpaperFromScheme {
            scheme = config.colorScheme;
            width = 3840;
            height = 2160;
            logoScale = 5.0;
          };
          link-wallpaper = ''
            if [ ! -e ${dest} ]; then
              $DRY_RUN_CMD ln $VERBOSE_ARG -s ${default-wallpaper} ${dest}
              $DRY_RUN_CMD ${set-wallpaper-command}
            fi
          '';
        in
          lib.hm.dag.entryAfter ["writeBoundary" "clone-wallpapers"] link-wallpaper;
      };

      packages =
      let
        change-wallpaper = pkgs.writeShellScriptBin "chw" ''
          file=$(find ${wall-dir} -type f | shuf | ${pkgs.nsxiv}/bin/nsxiv -oiqt | head -n 1)
          [ ! -z $file ] && ln -sf $file ${dest}
          ${set-wallpaper-command}
        '';
      in
      [ change-wallpaper ];
    };

    xdg.desktopEntries.chw = {
      name = "Change Wallpaper";
      icon = "preferences-desktop-wallpaper";
      exec = "chw";
      terminal = false;
      categories = [ "Application" ];
    };
  };
}
