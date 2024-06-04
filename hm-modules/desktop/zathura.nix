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
      options = {
        selection-clipboard = "clipboard";
        font = with osConfig.defaultFonts.sans; "${name} ${toString size}";
        recolor = true;
      };
    };
  };
}
