{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.librewolf;
  inherit (pkgs.lib) mkTrueEnableOption;
in
{
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
        "browser.search.widget.inNavBar" = false;
        "browser.tabs.insertAfterCurrent" = true;
        "browser.uidensity" = 1;
        "devtools.theme" = "dark";
        "identity.fxaccounts.enabled" = true;
        "keyword.enabled" = false;
        "media.hardwaremediakeys.enabled" = false;
        "media.peerconnection.ice.no_host" = false;
        "mousewheel.system_scroll_override.enabled" = false;
        "network.dns.disableIPv6" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.resistFingerprinting.letterboxing" = true;
        "privacy.sanitize.sanitizeOnShutdown" = false;
      };
    };

    stylix.targets.librewolf.profileNames = [ "default" ];

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
      in
      {
        open-with-messaging-host-librewolf = {
          enable = cfg.openwith.enable;
          target = "${nmh-path}/open_with.json";
          text = # json
            ''
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
        keepassxc-native-messaging-host-librewolf = {
          enable = cfg.keepassxc.enable;
          target = "${nmh-path}/org.keepassxc.keepassxc_browser.json";
          text = # json
            ''
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
