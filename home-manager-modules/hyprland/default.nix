{ config, lib, pkgs, specialArgs, ... }:

let
  cfg = config.modules.hyprland;
  inherit (lib) mkDefault mkOption mkEnableOption;
in {
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland";
    extraOptions = mkOption {
      default = {
        "$mon1" = "";
        "$mon2" = "$mon1";
        "$mon3" = "$mon2";

        # monitor = name,resolution,position,scale
        monitor = [
          "$mon1,prefered,auto,1"
        ];

        workspace = [];
      };
    };
    autostart =
      builtins.mapAttrs
        (
          name: value:
            {
              enable = mkEnableOption "${name}";
              command = mkOption { default = value; };
            }
        )
        {
          copyq = "copyq --start-server";
          easyeffects = "easyeffects --gapplication-service";
          mako = "mako";
          megasync = "sleep 5 && megasync";
          swww = "sleep 0.5 && swww init";
          waybar = "waybar";
          wl-clipboard = "wl-clip-persist --clipboard regular";
          wlsunset = "wlsunset -s 18:00 -S 8:00 -t 4500";

          # TODO: Add kdeconnect & syncthing-tray
        };
    extraAutostart = with lib.types; mkOption {
      default = {};
      type = attrsOf str;
      apply = set: builtins.mapAttrs ( name: value: { enable = true; command = value; }) set;
    };
  };

  config = lib.mkIf cfg.enable {
    modules = {
      waybar.enable = mkDefault true;
      rofi.enable = mkDefault true;
      kitty.enable = mkDefault true;

      hyprland.autostart = let
        pkgPresent = pkg: (builtins.elem pkg config.home.packages);

        specials = { # Programs with non-standard default enable conditions
          waybar.enable = mkDefault config.modules.waybar.enable;
          wl-clipboard.enable = mkDefault cfg.autostart.copyq.enable;
        };

        defaults = lib.foldl
          ( # The default enable condition is a package's presence in the home.packages list
            acc: el:
              acc // {
                ${el}.enable = mkDefault (pkgPresent pkgs.${el});
              }
          )
          {}
          # Autostart programs not in specials
          (lib.lists.subtractLists (lib.attrNames specials) (lib.attrNames cfg.autostart));
      in
        defaults // specials;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = mkDefault true;
      xwayland.enable = mkDefault true;
      settings = let
        # User configured autostart
        autostart = lib.foldl # Fold them together into a string intermediated by " & "
          (acc: e: acc + e.command + " & ")
          ""
          (
            builtins.filter
              (e: e.enable)
              (builtins.attrValues (cfg.autostart // cfg.extraAutostart)) # Autostart set { enable; command; }
          );
      in
        # Concatenates the exec-once list with the generated autostart
        # TODO: Find a more elegant way to do this
        lib.attrsets.mapAttrs
          (n: v: if n == "exec-once" then v ++ [autostart] else v)
          (cfg.extraOptions // (import ./settings.nix));
    };

    home = {
      packages = with pkgs; with specialArgs.flakePkgs; [
        # TODO: Include copyq configs
        copyq
        hyprland-protocols
        hyprpicker
        hyprshot
        libnotify
        mako
        swww
        wlsunset
      ] ++ (if config.modules.rofi.enable then [ pkgs.rofi-power-menu ] else []);
    };
  };
}
