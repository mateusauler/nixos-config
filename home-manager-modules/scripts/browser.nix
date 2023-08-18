{ custom, config, lib, pkgs, options, ... }:

let
  cfg = config.modules.browser;
in {
  options.modules.browser = {
    enable = lib.mkEnableOption "browser";
    package = lib.mkOption { default = pkgs.librewolf; };
    executableName = lib.mkOption { default = "librewolf"; };
    module = lib.mkOption { default = options.modules.librewolf; };
    videoPlayer = lib.mkOption {
      default = {
        package = pkgs.mpv;
        executableName = "mpv";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    modules.browser.module.enable = true;
    home.packages =
    let
      browser = pkgs.writeShellScriptBin "browser" ''
        browser_cmd="${cfg.package}/bin/${cfg.executableName} --new-tab"
        video_player="${cfg.videoPlayer.package}/bin/${cfg.videoPlayer.executableName}"

        run_cmd="$browser_cmd"
        run_args=""

        args="$@"

        private=0

        set_priv() {
          case $run_cmd in
            $browser_cmd)
              append_arg_start "--private-window"
              ;;
            *)
              ;;
          esac
        }

        append_arg(){
          run_args="$run_args $1"
        }

        append_arg_start(){
          run_args="$1 $run_args"
        }

        for a in $args; do
          echo "$a" | grep -E "(youtube\.com/(watch|shorts)|youtu\.be|tiktok\.com)" > /dev/null && run_cmd="$video_player"

          case $a in
            -p|-P)
              private=1
              ;;
            *)
              append_arg $a
          esac
        done

        if [ $private -eq 1 ] ; then
          set_priv
        fi

        printf "%b" "$run_cmd $run_args\n"
        exec $run_cmd $run_args > /dev/null &
      '';
    in
    [
      cfg.package
      browser
    ];

    xdg.desktopEntries.browser = {
      name = "Browser wrapper";
      genericName = "Web Browser";
      comment = "Handle urls";
      exec = "browser %u";
      icon = "internet-web-browser";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" "application/x-xpinstall" ];
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
  };
}