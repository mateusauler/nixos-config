{ custom, config, lib, pkgs, ... }:

let
  cfg = config.modules.steam-xdg;
in {
  options.modules.steam-xdg = {
    enable = lib.mkEnableOption "steam-xdg";
    fakeHome = lib.mkOption { default = "${config.xdg.dataHome}/Steam/fakehome"; };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
    let
      steam-xdg = pkgs.writeShellScriptBin "steam" ''
        # Symlink a file to the fake home
        link_dir() {
          # Replace HOME with FAKEHOME in the link name
          link_name=$(echo $1 | sed "s|^${config.home.homeDirectory}|${cfg.fakeHome}|")

          # Creates the link's parent directory and symlinks it
          mkdir -p $(dirname $link_name)
          [ ! -d $link_name ] && ln -s $1 $link_name
        }

        mkdir -p ${config.home.homeDirectory}

        link_dir ${config.xdg.dataHome}               # ~/.local/share
        link_dir ${config.xdg.cacheHome}              # ~/.cache
        link_dir ${config.xdg.configHome}             # ~/.config
        link_dir ${config.home.homeDirectory}/.icons  # ~/.icons (lxappearance's mouse cursor theme)

        # If .steam exists in ~/ and not in the fake home, move it to the fake home
        [ -d ${config.home.homeDirectory}/.steam ] && [ ! -d ${cfg.fakeHome}/.steam ] && mv ${config.home.homeDirectory}/.steam ${cfg.fakeHome}/

        HOME=${cfg.fakeHome} exec ${pkgs.steam}/bin/steam $@
      '';
    in
    [ steam-xdg ];
  };
}