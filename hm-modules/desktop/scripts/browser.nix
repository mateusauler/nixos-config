{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.browser;
  inherit (lib) mkOption;

  notify-send = lib.getExe pkgs.libnotify;
in
{
  options.modules.browser = {
    enable = lib.mkEnableOption "browser";
    browserCommand = mkOption { default = lib.getExe config.programs.librewolf.package; };
    videoPlayer = mkOption {
      default = lib.getExe (
        if config.programs.mpv.enable then config.programs.mpv.finalPackage else pkgs.mpv
      );
    };
    playerParams = mkOption { default = "--msg-level=all=error"; };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      BROWSER = "browser";
      BROWSER_PRIV = "browser -p";
      BROWSER_PROF = "browser --ProfileManager";
    };

    home.packages = [
      (pkgs.writeShellScriptBin "browser" # bash
        ''
          browser_cmd="${cfg.browserCommand} --new-tab"

          run_cmd="$browser_cmd"
          run_args=""

          set_priv() {
            case $run_cmd in
              $browser_cmd)
                prepend_arg "--private-window"
                ;;
              *)
                ;;
            esac
          }

          append_arg() {
            run_args="$run_args $1"
          }

          prepend_arg() {
            run_args="$1 $run_args"
          }

          set_player() {
            run_cmd="${cfg.videoPlayer}"
            prepend_arg "${cfg.playerParams}"
          }

          for arg in "$@"
          do
            if grep -E "(youtube\.com/(watch|shorts)|youtu\.be|tiktok\.com|instagram\.com/reel)" > /dev/null <<< "$arg"
            then
              set_player
            fi

            case $arg in
              -p|-P)
                set_priv
                ;;
              *)
                append_arg $arg
                ;;
            esac
          done

          printf "%b\n" "$run_cmd $run_args"
          ${notify-send} Browser "$(basename "$run_cmd") $run_args"

          msg=$($run_cmd $run_args)
          if [[ $? -ne 0 ]]
          then
            printf "%b" "$msg"
            ${notify-send} Error "$msg"
          fi
        ''
      )
    ];

    xdg.desktopEntries.browser = {
      name = "Browser wrapper";
      genericName = "Web Browser";
      comment = "Handle urls";
      exec = "browser %u";
      icon = "internet-web-browser";
      terminal = false;
      categories = [
        "Application"
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xht"
        "application/x-extension-xhtml"
        "application/xhtml+xml"
        "application/x-xpinstall"
        "text/html"
        "text/xml"
        "x-scheme-handler/chrome"
        "x-scheme-handler/ftp"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        "new-window" = {
          name = "New Window";
          exec = "browser --new-window %u";
        };
        "new-private-window" = {
          name = "New Private Window";
          exec = "browser -p %u";
        };
      };
    };

    xdg.mimeApps.defaultApplications = lib.genAttrs config.xdg.desktopEntries.browser.mimeType (
      _: "browser.desktop"
    );
  };
}
