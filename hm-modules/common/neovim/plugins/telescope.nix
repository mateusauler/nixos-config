{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    extraPackages = lib.optionals cfg-plug.telescope.enable [
      pkgs.fd
      pkgs.ripgrep
    ];

    plugins.telescope = {
      keymaps = {
        "<leader>ff" = { action = "find_files"; options.desc = "Telescope: Find files"; };
        "<leader>fg" = { action = "live_grep";  options.desc = "Telescope: Live grep";  };
        "<leader>fb" = { action = "buffers";    options.desc = "Telescope: Buffers";    };
        "<leader>fh" = { action = "help_tags";  options.desc = "Telescope: Help tags";  };
      };

      settings = {
        defaults.vimgrep_arguments =
          config.lib.nixvim.mkRaw # lua
            ''
              (function()
                local telescopeConfig = require("telescope.config")
                local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
                table.insert(vimgrep_arguments, "--hidden")
                table.insert(vimgrep_arguments, "--glob")
                table.insert(vimgrep_arguments, "!**/.git/*")
                return vimgrep_arguments
              end)()
            '';

        pickers.find_files.find_command = [
          "rg"
          "--files"
          "--hidden"
          "--glob"
          "!**/.git/*"
        ];
      };
    };
  };
}
