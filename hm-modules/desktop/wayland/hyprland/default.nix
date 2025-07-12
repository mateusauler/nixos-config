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
    auto-run-command = mkOption {
      default = "Hyprland";
      readOnly = true;
    };
  };

  imports = [ ./settings.nix ];

  config = lib.mkIf cfg.enable {
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
