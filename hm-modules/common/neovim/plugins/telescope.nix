{ config, lib, nixpkgs-channel, pkgs, ... }:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;

  keymaps = {
    "<leader>ff" = { action = "find_files"; options.desc = "Telescope: Find files"; };
    "<leader>fg" = { action = "live_grep";  options.desc = "Telescope: Live grep";  };
    "<leader>fb" = { action = "buffers";    options.desc = "Telescope: Buffers";    };
    "<leader>fh" = { action = "help_tags";  options.desc = "Telescope: Help tags";  };
  };

  settings = {
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

    pickers.find_files.find_command = [ "rg" "--files" "--hidden" "--glob" "!**/.git/*" ];
  };
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    extraPackages = lib.optionals cfg-plug.telescope.enable [ pkgs.fd pkgs.ripgrep ];

    plugins.telescope = {
      keymaps = lib.mapAttrs
        (_: value:
          if nixpkgs-channel == "stable" then
            { inherit (value) action; } // value.options
          else
            value
        )
        keymaps;
      } // (if nixpkgs-channel == "stable" then {
        inherit (settings) defaults;
        extraOptions = { inherit (settings) pickers; };
      } else { inherit settings; });
  };
}
