{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.hyprland;
  inherit (lib) mkDefault mkOption mkEnableOption;
in
{
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland";
    modKey = mkOption { default = "SUPER"; };
  };

  imports = [ ./settings.nix ];

  config = lib.mkIf cfg.enable {
    programs.fish.loginShellInit = # fish
      ''
        [ -z "$DISPLAY" ] && test (tty) = "/dev/tty1" && Hyprland
      '';

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = mkDefault true;
      xwayland.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      hyprpicker
      hyprshot
    ];
  };
}
