{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.modules.zathura;
in
{
  options.modules.zathura.enable = lib.mkEnableOption "Zathura";

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = with config.colorScheme.palette; {
        selection-clipboard = "clipboard";
        font = with osConfig.defaultFonts.sans; "${name} ${toString size}";
        recolor = true;
        default-bg = "#${base00}";
        default-fg = "#${base01}";
        statusbar-bg = "#${base02}";
        statusbar-fg = "#${base04}";
        inputbar-bg = "#${base00}";
        inputbar-fg = "#${base07}";
        notification-bg = "#${base00}";
        notification-fg = "#${base07}";
        notification-error-bg = "#${base00}";
        notification-error-fg = "#${base08}";
        notification-warning-bg = "#${base00}";
        notification-warning-fg = "#${base08}";
        highlight-color = "#${base0A}";
        highlight-active-color = "#${base0D}";
        completion-bg = "#${base01}";
        completion-fg = "#${base05}";
        recolor-lightcolor = "#${base00}";
        recolor-darkcolor = "#${base06}";
      };
    };
  };
}
