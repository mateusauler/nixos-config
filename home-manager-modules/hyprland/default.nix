{ config, lib, pkgs, specialArgs, ... }@args:

let
  cfg = config.modules.hyprland;
  module-names = [ "kitty" "mako" "rofi" "waybar" ];
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
          megasync = "megasync";
          swww = "sleep 0.5 && swww init";
          waybar = "waybar";
          wl-clip-persist = "wl-clip-persist --clipboard regular";
          wlsunset = "wlsunset -s 18:00 -S 8:00 -t 4500";

          # TODO: Add kdeconnect & syncthing-tray
        };
    autostart-wait-for = { megasync.wait-for = mkOption { default = "waybar"; }; };
    extraAutostart = with lib.types; mkOption {
      default = { };
      type = attrsOf str;
      apply = set: builtins.mapAttrs ( name: value: { enable = true; command = value; }) set;
    };
  };

  config = lib.mkIf cfg.enable {
    modules = (pkgs.lib.enableModules { inherit module-names; }) // {
      hyprland.autostart = let
        pkgPresent = pkg: (builtins.elem pkg config.home.packages);

        specials = { # Programs with non-standard default enable conditions
          waybar.enable = mkDefault config.modules.waybar.enable;
          wl-clip-persist.enable = mkDefault cfg.autostart.copyq.enable;
        };

        defaults = lib.foldl
          # The default enable condition is a package's presence in the home.packages list
          (acc: el: acc // { ${el}.enable = mkDefault (pkgPresent pkgs.${el}); })
          { }
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
          # TODO: Find a better way to modify the commands with the wait-for logic
          (map # Apply the wait-for logic on the commands
            (v: v //
              {command =
                # Prepend the waiting machinery to the command
                if lib.attrsets.hasAttrByPath [ "wait-for" ] v then
                  # TODO: Improve the wait-for machinery
                  "while ! [ $(pgrep ${v.wait-for}) ]; do sleep 1; done && sleep 2 && ${v.command}"
                else
                  v.command;
              }
            )
            (builtins.filter # Filter the enabled commands
              (e: e.enable)
              (builtins.attrValues # Get the command sets as a list
                (lib.recursiveUpdate # Append wait-for option to command sets that need it
                  (cfg.autostart // cfg.extraAutostart)
                  cfg.autostart-wait-for
                )
              )
            )
          );
      in
        # Concatenates the exec-once list with the generated autostart
        # TODO: Find a more elegant way to do this
        lib.attrsets.mapAttrs
          (n: v: if n == "exec-once" then v ++ [autostart] else v)
          (cfg.extraOptions // import ./settings.nix args);
    };

    home = {
      packages = with pkgs; [
        # TODO: Include copyq configs
        copyq
        hyprland-protocols
        hyprpicker
        hyprshot
        libnotify
        swww
        wl-clip-persist
        wlsunset
      ] ++ (if config.modules.rofi.enable then [ pkgs.rofi-power-menu ] else []);
    };
  };
}
