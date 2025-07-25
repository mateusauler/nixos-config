{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.xdg.compliance;
  inherit (config.xdg) cacheHome configHome dataHome  stateHome;
in
{
  # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
  # https://github.com/b3nj5m1n/xdg-ninja

  options.modules.xdg.compliance.enable = pkgs.lib.mkEnableOption "XDG base directory compliance for (some) non-compliant programs";

  config = lib.mkIf (cfg.enable && config.modules.xdg.enable) {
    home.sessionVariables = rec {
      DOCKER_CONFIG          = "${configHome}/docker";
      RUSTUP_HOME            = "${dataHome}/rustup";
      ADB_KEYS_PATH          = ANDROID_PREFS_ROOT;
      ANDROID_HOME           = "${dataHome}/android";
      ANDROID_PREFS_ROOT     = "${configHome}/android";
      ANDROID_USER_HOME      = "${dataHome}/android";
      CARGO_HOME             = "${dataHome}/cargo";
      DOTNET_CLI_HOME        = "${dataHome}/dotnet";
      GNUPGHOME              = "${dataHome}/gnupg";
      GOPATH                 = "${dataHome}/go";
      GRADLE_USER_HOME       = "${dataHome}/gradle";
      _JAVA_OPTIONS          = "-Djava.util.prefs.userRoot=${configHome}/java";
      LESSHISTFILE           = "-";
      NODE_REPL_HISTORY      = "${stateHome}/node_repl_history";
      NPM_CONFIG_USERCONFIG  = "${configHome}/npm/npmrc";
      NPM_CONFIG_INIT_MODULE = "${configHome}/npm/config/npm-init.js";
      NPM_CONFIG_CACHE       = "${cacheHome}/npm";
      NPM_CONFIG_TMP         = "$XDG_RUNTIME_DIR/npm";
      NUGET_PACKAGES         = "${cacheHome}/NuGetPackages";
      NVM_DIR                = "${dataHome}/nvm";
      PSQL_HISTORY           = "${stateHome}/psql_history";
      PYTHON_HISTORY         = "${cacheHome}/python_history";
      SQLITE_HISTORY         = "${dataHome}/sqlite_history";
      W3M_DIR                = "${dataHome}/w3m";
      WINEPREFIX             = "${dataHome}/wineprefixes/default";
    };

    xresources.path = "${configHome}/X11/xresources";

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
  };
}
