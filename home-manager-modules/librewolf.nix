{ config, lib, pkgs, ... }:

let
  cfg = config.modules.librewolf;
in {
  options.modules.librewolf.enable = lib.mkEnableOption "librewolf";

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
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
  };
}
