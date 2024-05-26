{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.steam-xdg;
in
{
  options.modules.steam-xdg = {
    enable = lib.mkEnableOption "steam-xdg";
    fakeHome = lib.mkOption { default = "${config.xdg.dataHome}/Steam/fakehome"; };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        inherit (config.home) homeDirectory;
        steam-xdg =
          pkgs.writeShellScriptBin "steam" # bash
            ''
              # Symlink a file to the fake home
              link_dir() {
                # Replace HOME with FAKEHOME in the link name
                link_name=$(echo $1 | sed "s|^${homeDirectory}|${cfg.fakeHome}|")

                # Creates the link's parent directory and symlinks it
                mkdir -p $(dirname "$link_name")
                if [ ! -d "$link_name" ]; then
                  ln -s "$1" "$link_name"
                fi
              }

              mkdir -p ${cfg.fakeHome}

              # Remove every link in the fake home
              find ${cfg.fakeHome} -maxdepth 1 -type l -delete

              # If .steam exists in ~/, move it to the fake home, updating the newer files
              if [ -d ${homeDirectory}/.steam ]; then
                mv -uf ${homeDirectory}/.steam/* ${cfg.fakeHome}/.steam
                rmdir ${homeDirectory}/.steam
              fi
              # Remove runtime steam files from the user's home
              rm -f ${homeDirectory}/.steampath ${homeDirectory}/.steampid

              # Export the function so we can use it in a new bash context
              export -f link_dir
              # Link every file in the root of the home directory to the fake home
              find ${homeDirectory} -maxdepth 1 | xargs -P$(nproc) -I{} bash -c 'link_dir "$0"' {}

              HOME=${cfg.fakeHome} exec ${lib.getExe pkgs.steam} $@
            '';
      in
      [ steam-xdg ];
  };
}
