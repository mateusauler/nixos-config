{ custom, config, lib, pkgs, nix-colors, ... }:

let
  inherit (lib) mkDefault;
  inherit (custom) dots-path color-scheme;

  module-names = [ "bat" "fish" "neovim" "wget" "xdg" ];
in {
  imports = [
    nix-colors.homeManagerModules.default
  ];

  colorScheme = mkDefault nix-colors.colorSchemes.${color-scheme};

  programs.home-manager.enable = true;

  modules = pkgs.lib.enableModules module-names;

  home = {
    sessionVariables = with config.xdg; rec {
      TERMINAL              = "$TERM";
      COLORTERM             = "$TERM";

      VISUAL                = "$EDITOR";

      MANPAGER              = "bat -l man -p";

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
      PYTHONSTARTUP         = config.xdg.configFile."python/pythonrc".target;
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
