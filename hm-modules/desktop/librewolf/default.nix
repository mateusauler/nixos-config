{ config, lib, pkgs, ... }:

let
  cfg = config.modules.librewolf;
  inherit (lib) mkDefault;
  inherit (pkgs.lib) mkTrueEnableOption;
in {
  options.modules.librewolf = {
    enable = lib.mkEnableOption "librewolf";
    openwith.enable = mkTrueEnableOption "openwith";
    keepassxc.enable = mkTrueEnableOption "keepassxc";
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf-wayland;
      settings = {
        "privacy.resistFingerprinting.letterboxing" = true;
        "network.dns.disableIPv6" = false;
        "media.peerconnection.ice.no_host" = false;
        "identity.fxaccounts.enabled" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "browser.uidensity" = 1;
        "mousewheel.system_scroll_override.enabled" = false;
        "devtools.theme" = "dark";
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "keyword.enabled" = false;
        "browser.search.widget.inNavBar" = false;
      };
    };

    xdg.dataFile.open-with-script = {
      enable = cfg.openwith.enable;
      executable = true;
      target = "openwith/open_with_linux.py";
      text = ''
        #!${lib.getExe pkgs.python3}
        ${builtins.readFile ./open_with_linux.py}
      '';
    };

    home.file =
      let
        nmh-path = ".librewolf/native-messaging-hosts";
      in {
        open-with-messaging-host = {
          enable = cfg.openwith.enable;
          target = "${nmh-path}/open_with.json";
          text = ''
            {
              "allowed_extensions": [
                "openwith@darktrojan.net"
              ],
              "description": "Open With native host",
              "name": "open_with",
              "path": "${config.home.homeDirectory}/${config.xdg.dataFile.open-with-script.target}",
              "type": "stdio"
            }
          '';
        };
        keepassxc-native-messaging-host = {
          enable = cfg.keepassxc.enable;
          target = "${nmh-path}/org.keepassxc.keepassxc_browser.json";
          text = ''
            {
              "allowed_extensions": [
                "keepassxc-browser@keepassxc.org"
              ],
              "description": "KeePassXC integration with native messaging support",
              "name": "org.keepassxc.keepassxc_browser",
              "path": "${pkgs.keepassxc}/bin/keepassxc-proxy",
              "type": "stdio"
            }
          '';
        };
      };
  };
}
