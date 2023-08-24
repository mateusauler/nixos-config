{ inputs, custom, config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault;
  inherit (custom) username dots-path;

  module-names = [ "fish" "wget" ];
in {
  programs.home-manager.enable = true;

  modules = pkgs.lib.my.enableModules { inherit module-names; };

  xdg = {
    enable = mkDefault true;
    userDirs = {
      enable = mkDefault true;
      desktop   = mkDefault null;
      documents = mkDefault "${config.home.homeDirectory}/docs";
      download  = mkDefault "${config.home.homeDirectory}/dl";
      music     = mkDefault "${config.home.homeDirectory}/music";
      pictures  = mkDefault "${config.home.homeDirectory}/pics";
      videos    = mkDefault "${config.home.homeDirectory}/vids";
    };
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = rec {
      TERMINAL                    = "$TERM";
      COLORTERM                   = "$TERM";

      VISUAL                      = "$EDITOR";
      DIFFPROG                    = "meld";

      MANPAGER                    = "bat -l man -p";

      BROWSER                     = "browser";
      BROWSER_PRIV                = "browser -p";
      BROWSER_PROF                = "browser --ProfileManager";

      # Fix android studio
      CHROME_EXECUTABLE           = "`${lib.getBin pkgs.bash}/bin/bash -c 'which chromium' 2> /dev/null`";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # Cleanup ~/
      XAUTHORITY                  = "$XDG_RUNTIME_DIR/Xauthority";
      XINITRC                     = "${config.xdg.configHome}/X11/xinitrc";
      LESSHISTFILE                = "-";
      GNUPGHOME                   = "${config.xdg.dataHome}/gnupg";
      WINEPREFIX                  = "${config.xdg.dataHome}/wineprefixes/default";
      GOPATH                      = "${config.xdg.dataHome}/go";
      SQLITE_HISTORY              = "${config.xdg.dataHome}/sqlite_history";
      CCACHE_CONFIGPATH           = "${config.xdg.configHome}/ccache.config";
      CCACHE_DIR                  = "${config.xdg.cacheHome}/ccache";
      ANDROID_PREFS_ROOT          = "${config.xdg.configHome}/android";
      ADB_KEYS_PATH               = "${ANDROID_PREFS_ROOT}";
      ANDROID_HOME                = "${config.xdg.dataHome}/android";
      ANDROID_EMULATOR_HOME       = "${ANDROID_HOME}/emulator";
      _JAVA_OPTIONS               = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
      NPM_CONFIG_USERCONFIG       = "${config.xdg.configHome}/npm/npmrc";
      NVM_DIR                     = "${config.xdg.dataHome}/nvm";
      CARGO_HOME                  = "${config.xdg.dataHome}/cargo";
      CUDA_CACHE_PATH             = "${config.xdg.cacheHome}/nv";
      GRADLE_USER_HOME            = "${config.xdg.dataHome}/gradle";
      JUPYTER_CONFIG_DIR          = "${config.xdg.configHome}/jupyter";
      CABAL_CONFIG                = "${config.xdg.configHome}/cabal/config";
      CABAL_DIR                   = "${config.xdg.cacheHome}/cabal";
      PYTHONSTARTUP               = "${config.xdg.configHome}/python/pythonrc";
      HISTFILE                    = "${config.xdg.stateHome}/bash/history";
    };

    packages = with pkgs; [
      btop
      du-dust
      htop-vim
      meld
      tldr
    ];

    activation.clone-dots = lib.hm.dag.entryAfter ["writeBoundary"] (
      # TODO: Only change the remote url to ssh if there is a key available
      pkgs.lib.my.cloneRepo {
        path = dots-path;
        url = "https://github.com/mateusauler/nixos-config";
        ssh-uri = "git@github.com:mateusauler/nixos-config.git";
      }
    );
  };

  xdg.configFile."nixpkgs/config.nix" = {
    enable = true;
    text = "{ allowUnfree = true; }";
  };
}
