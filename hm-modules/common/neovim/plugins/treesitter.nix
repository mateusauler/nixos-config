{ config, lib, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.treesitter = {
    settings.indent.enable = true;
    nixvimInjections = true;
  };
}
