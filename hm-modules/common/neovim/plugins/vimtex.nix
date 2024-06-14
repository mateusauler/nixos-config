{ config, lib, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.vimtex = {
    texlivePackage = null;
    settings = lib.optionalAttrs config.programs.zathura.enable { view_method = "zathura"; };
  };
}
