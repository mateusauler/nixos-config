{ config, lib, pkgs, ... }:

let
  cfg = config.modules.power-menu;

  inherit (lib) mkOption mkDefault;
in
{
  options.modules.power-menu = {
    enable = lib.mkEnableOption "Power menu";
    command = {
      line = mkOption { default = "${pkgs.wofi}/bin/wofi --columns 1 --dmenu"; };
      prompt-arg = mkOption { default = "--prompt"; };
    };
    actions = with lib.types; mkOption {
      type = attrsOf (submodule {
        options = {
          enable = pkgs.lib.mkTrueEnableOption null;
          confirm = mkOption { type = bool; default = true; };
          icon = mkOption { type = str; };
          text = mkOption { type = str; };
          command = mkOption { type = str; };
        };
      });
    };
    icons = pkgs.lib.mkTrueEnableOption "icons";
  };

  config = lib.mkIf cfg.enable {
    modules.power-menu.actions = lib.mapAttrs (_: lib.mapAttrs (_: mkDefault)) {
      shutdown = { icon = ""; text = "Shut Down"; command = "systemctl poweroff"; };
      reboot = { icon = ""; text = "Reboot"; command = "systemctl reboot"; };
      firmware = { icon = ""; text = "Reboot to UEFI firmware interface"; command = "systemctl reboot --firmware-setup"; };
      logout = { icon = ""; text = "Log out"; command = "loginctl terminate-session \${XDG_SESSION_ID-}"; };
    };

    home.packages =
      let
        genLabel = value: (lib.optionalString cfg.icons value.icon + "  ") + value.text;

        actionList = lib.filter (a: a.enable) (lib.attrValues cfg.actions);

        actionLabels = map genLabel actionList;

        options = lib.concatStringsSep "\\n" actionLabels;

        promptCommand = with cfg.command; "${line} ${prompt-arg}";

        confirmation = action: lib.optionalString action.confirm ''[ "$(printf "Yes\nNo" | ${promptCommand} "Are you sure you want to ${action.text}?")" = "Yes" ] &&'';

        power-menu = pkgs.writeShellScriptBin "power-menu" ''
          choice=$(printf "${options}" | ${promptCommand} "What do you want to do?")

          case "$choice" in
            ${
              lib.concatMapStrings (action: ''
                "${genLabel action}")
                  ${confirmation action} ${action.command}
                  ;;
              '')
              actionList
            }
            *)
              echo "Unknown action: '$choice'" >&2
              exit 1
              ;;
          esac
        '';
      in
      [ power-menu ];
  };
}
