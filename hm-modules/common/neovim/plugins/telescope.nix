{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    extraPackages = lib.optional cfg-plug.telescope.enable pkgs.fd;

    plugins.telescope = {
      keymaps = {
        "<leader>ff" = { action = "find_files"; desc = "Telescope: Find files"; };
        "<leader>fg" = { action = "live_grep";  desc = "Telescope: Live grep"; };
        "<leader>fb" = { action = "buffers";    desc = "Telescope: Buffers"; };
        "<leader>fh" = { action = "help_tags";  desc = "Telescope: Help tags"; };
      };

      # FIXME: Use mkRaw helper once I figure out how to get helpers working
      defaults.vimgrep_arguments.__raw = /* lua */ ''
        (function()
          local telescopeConfig = require("telescope.config")
          local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
          table.insert(vimgrep_arguments, "--hidden")
          table.insert(vimgrep_arguments, "--glob")
          table.insert(vimgrep_arguments, "!**/.git/*")
          return vimgrep_arguments
        end)()
      '';

      extraOptions.pickers.find_files.find_command = [ "rg" "--files" "--hidden" "--glob" "!**/.git/*" ];
    };
  };
}
