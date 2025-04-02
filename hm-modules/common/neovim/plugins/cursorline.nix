{ config, lib, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.cursorline.settings = {
    cursorline = {
      timeout = 450;
      number = true;
    };
    cursorword.enable = false;
  };
}
