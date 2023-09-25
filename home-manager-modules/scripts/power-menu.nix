{ config, lib, pkgs, ... }:

let
  cfg = config.modules.power-menu;

  inherit (lib) mkOption mkDefault;
in
{
  options.modules.power-menu = {
    enable = lib.mkEnableOption "Power menu";
    command = {
      line = mkOption { default = "${pkgs.wofi}/bin/wofi --dmenu"; };
      prompt-arg = mkOption { default = "--prompt"; };
    };
    actions = with lib.types; mkOption {
      type = attrsOf (submodule {
        options = {
          enable = pkgs.lib.mkTrueEnableOption null;
          icon = mkOption { type = str; };
          text = mkOption { type = str; };
          command = mkOption { type = str; };
        };
      });
    };
    icons = pkgs.lib.mkTrueEnableOption "icons";
  };

  config = lib.mkIf cfg.enable {
    modules.power-menu.actions = {
      shutdown = { icon = mkDefault ""; text = mkDefault "Shut Down"; command = mkDefault "systemctl poweroff"; };
      reboot = { icon = mkDefault ""; text = mkDefault "Reboot"; command = mkDefault "systemctl reboot"; };
    };

    home.packages =
      let
        genLabel = value: (lib.optionalString cfg.icons value.icon + "  ") + value.text;

        enabledActions = lib.filterAttrs (_: v: v.enable) cfg.actions;

        actionLablesAndCommands = lib.foldlAttrs (acc: _: value: acc ++ [{ command = value.command; label = genLabel value; }]) [ ] enabledActions;

        actionLabels = map (a: a.label) actionLablesAndCommands;

        options = lib.concatStringsSep "\\n" actionLabels;

        power-menu = pkgs.writeShellScriptBin "power-menu" ''
          choice=$(printf "${options}" | ${cfg.command.line} ${cfg.command.prompt-arg} "What do you want to do?")
          case "$choice" in
            ${
              lib.concatMapStrings (a: ''
                "${a.label}")
                  ${a.command}
                  ;;
              '')
              actionLablesAndCommands
            }
            *)
              echo "Unknown action: $choice" >&2
              exit 1
              ;;
          esac
        '';
      in
      [ power-menu ];
  };
}
