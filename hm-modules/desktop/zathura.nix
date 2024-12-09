{ config, lib, ... }:

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
        font = with config.stylix.fonts; "${sansSerif.name} ${toString sizes.applications}";
        recolor = true;
        database = "sqlite";
      };
    };
  };
}
