{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    keymaps = lib.optionals cfg-plug.flash.enable [
      { key = "s";     mode = [ "n" "x" "o" ]; action.__raw = "require('flash').jump";              options.desc = "Flash"; }
      { key = "S";     mode = [ "n" "x" "o" ]; action.__raw = "require('flash').treesitter";        options.desc = "Flash Treesitter"; }
      { key = "r";     mode = "o";             action.__raw = "require('flash').remote";            options.desc = "Remote Flash"; }
      { key = "R";     mode = [ "o" "x" ];     action.__raw = "require('flash').treesitter_search"; options.desc = "Treesitter Search"; }
      { key = "<C-s>"; mode = "c";             action.__raw = "require('flash').toggle";            options.desc = "Toggle Flash Search"; }
      { key = "<C-s>"; mode = [ "n" "x" "o" ]; action = "s"; }
    ];

    plugins.flash.settings.jump = {
      autojump = true;
      nohlsearch = true;
    };
  };

}
