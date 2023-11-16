{ custom, config, inputs, lib, pkgs, nix-colors, ... }@args:

let
  inherit (lib) mkDefault;
  inherit (custom) dots-path color-scheme;

  system-base-module = import ../modules/base.nix args;

  module-names = [ "bat" "fish" "neovim" "wget" "xdg" ];
in {
  imports = [ nix-colors.homeManagerModules.default ];

  colorScheme = mkDefault nix-colors.colorSchemes.${color-scheme};

  programs.home-manager.enable = true;

  modules = pkgs.lib.enableModules module-names;

  home = {
    sessionVariables = with config.xdg; rec {
      TERMINAL              = "$TERM";
      COLORTERM             = "$TERM";

      VISUAL                = "$EDITOR";

      # Cleanup ~/
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

    packages = with pkgs; [
      btop
      du-dust
      htop-vim
      tldr
    ];

    activation.clone-dots = lib.hm.dag.entryAfter ["writeBoundary"] (
      # TODO: Only change the remote url to ssh if there is a key available
      pkgs.lib.cloneRepo {
        path = dots-path;
        url = "https://github.com/mateusauler/nixos-config";
        ssh-uri = "git@github.com:mateusauler/nixos-config.git";
      }
    );
  };

  # Use the same nix settings in home-manager as in the full system config
  # This is useful if using standalone home-manager
  nix.settings = system-base-module.nix.settings;

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

    "nixpkgs/config.nix".text = "{ allowUnfree = true; }";
  };
}
