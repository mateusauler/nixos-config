{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.modules.hyprland;
  module-names = [ "copyq" "kitty" "mako" "swaylock" "waybar" "wofi" ];
  inherit (lib) mkDefault mkOption mkEnableOption;
in
{
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland";
    modKey = mkOption { default = "SUPER"; };
    disable-middle-paste = mkOption { default = true; };
    autostart =
      (builtins.mapAttrs
        (name: value: {
          enable = mkEnableOption name;
          command = mkOption { default = value; };
        })
        {
          copyq = "copyq --start-server";
          easyeffects = "easyeffects --gapplication-service";
          waybar = "waybar";
          wl-clip-persist = "wl-clip-persist --clipboard regular";
          wlsunset = "wlsunset -s 18:00 -S 8:00 -t 4500";
          xwaylandvideobridge = "xwaylandvideobridge";
          # TODO: Add kdeconnect & syncthing-tray
        }) // {
        apply-wallpaper = {
          enable = mkEnableOption "apply-wallpaper";
          command = mkOption { type = lib.types.str; };
        };
      };
    extraAutostart = with lib.types; mkOption {
      default = { };
      type = attrsOf str;
      apply = set: builtins.mapAttrs (name: value: { enable = true; command = value; }) set;
    };
  };

  imports = [ ./settings.nix ];

  config = lib.mkIf cfg.enable {
    programs.fish.loginShellInit = /* fish */ "[ -z \"$DISPLAY\" ] && test (tty) = \"/dev/tty1\" && Hyprland";

    modules = pkgs.lib.enableModules module-names // {
      hyprland.autostart =
        let
          pkgPresent = pkg: (builtins.elem pkg config.home.packages);

          specials = {
            # Programs with non-standard default enable conditions
            apply-wallpaper.enable = with config.modules.change-wallpaper; mkDefault (enable && command != null);
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
      systemd.enable = mkDefault true;
      xwayland.enable = mkDefault true;
      # User configured autostart
      settings.exec-once = map # Map the list of command attrsets into a list of command strings
        (e: e.command)
        (builtins.filter # Filter the enabled commands
          (e: e.enable)
          (builtins.attrValues # Get the command sets as a list
            (cfg.autostart // cfg.extraAutostart)
          )
        );
    };

    home.packages = with pkgs; lib.flatten [
      hyprland-protocols
      hyprpicker
      libnotify
      playerctl
      wl-clip-persist
      wlsunset
      # FIXME: Install normally, when hyprshot gets to stable
      pkgs-unstable.hyprshot
      (lib.optional config.wayland.windowManager.hyprland.xwayland.enable xwaylandvideobridge)
      (lib.optional config.modules.rofi.enable rofi-power-menu)
    ];
  };
}
