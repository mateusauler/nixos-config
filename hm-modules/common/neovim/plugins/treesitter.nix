{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim.plugins.treesitter = {
    nixvimInjections = true;
    settings.indent.enable = true;
  };
}
