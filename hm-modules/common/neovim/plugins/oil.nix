{
  config,
  inputs,
  lib,
  nixpkgs-channel,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;
  enabled = config.programs.nixvim.plugins.oil.enable;
  settings = {
    default_file_explorer = true;
    experimental_watch_for_changes = true;
  };
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    globals = lib.optionalAttrs enabled { netrw_nogx = 1; };

    keymaps = lib.optionals enabled [
      {
        mode = "n";
        key = "-";
        action = "<Cmd>Oil<CR>";
        options.desc = "Oil: Open parent directory";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "gx";
        action = "<Cmd>Browse<CR>";
      }
    ];

    extraConfigLua =
      lib.optionalString enabled # lua
        ''
          require("gx").setup({
            handler_options = { search_engine = "duckduckgo" },
          })
        '';

    plugins.oil =
      if nixpkgs-channel == "stable" then { extraOptions = settings; } else { inherit settings; };

    extraPlugins = lib.optional enabled (
      pkgs.vimUtils.buildVimPlugin {
        name = "gx";
        src = inputs.gx;
      }
    );
  };
}
