{ config, lib, pkgs, ... }:

let
  cfg = config.modules.xdg.compliance;
in
{
  # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
  # https://github.com/b3nj5m1n/xdg-ninja

  options.modules.xdg.compliance.enable = pkgs.lib.mkEnableOption "XDG base directory compliance for (some) non-compliant programs";

  config = lib.mkIf (cfg.enable && config.modules.xdg.enable) {
    home.sessionVariables = with config.xdg; rec {
      DOCKER_CONFIG         = "${configHome}/docker";
      RUSTUP_HOME           = "${dataHome}/rustup";
      ADB_KEYS_PATH         = ANDROID_PREFS_ROOT;
      ANDROID_HOME          = "${dataHome}/android";
      ANDROID_PREFS_ROOT    = "${configHome}/android";
      CARGO_HOME            = "${dataHome}/cargo";
      GNUPGHOME             = "${dataHome}/gnupg";
      GOPATH                = "${dataHome}/go";
      GRADLE_USER_HOME      = "${dataHome}/gradle";
      _JAVA_OPTIONS         = "-Djava.util.prefs.userRoot=${configHome}/java";
      LESSHISTFILE          = "-";
      NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
      NVM_DIR               = "${dataHome}/nvm";
      PYTHONSTARTUP         = "${configHome}/python/pythonrc";
      SQLITE_HISTORY        = "${dataHome}/sqlite_history";
      WINEPREFIX            = "${dataHome}/wineprefixes/default";
    };

    xdg.configFile."nix/nix.conf".onChange =
      let
        home = config.home.homeDirectory;
        stateHome = config.xdg.stateHome or "${home}/.local/state";
        mv = source: destination: "$DRY_RUN_CMD test -f ${source} && mv ${source} ${destination} || true";
      in
        lib.optionalString config.nix.settings.use-xdg-base-directories or false ''
          $DRY_RUN_CMD mkdir -p ${stateHome}
          ${mv "${home}/.nix-profile" "${stateHome}/profile"}
          ${mv "${home}/.nix-defexpr" "${stateHome}/defexpr"}
          ${mv "${home}/.nix-channels" "${stateHome}/channels"}
        '';

    xdg.configFile = {
      "python/pythonrc".text = ''
        import os
        import atexit
        import readline

        history = os.path.join(os.environ['XDG_CACHE_HOME'], 'python_history')
        try:
          readline.read_history_file(history)
        except OSError:
          pass

        def write_history():
          try:
            readline.write_history_file(history)
          except OSError:
            pass

        atexit.register(write_history)
      '';
    };
  };
}
