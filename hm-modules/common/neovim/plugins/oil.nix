{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.neovim;
  inherit (config.programs.nixvim.plugins.oil) enable;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    keymaps = lib.optionals enable [
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

    plugins = {
      gx = {
        inherit enable;
        settings.handler_options.search_engine = "duckduckgo";
      };
      oil.settings = {
        default_file_explorer = true;
        experimental_watch_for_changes = true;
        skip_confirm_for_simple_edits = true;
        view_options = {
          show_hidden = true;
          is_always_hidden = # lua
            ''
              function(name, _)
                return name == '..' or name == '.git'
              end
            '';
        };
      };
    };
  };
}
