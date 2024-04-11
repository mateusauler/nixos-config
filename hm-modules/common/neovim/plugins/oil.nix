{ config, inputs, lib, nixpkgs-channel, pkgs, ... }:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
  settings = {
    default_file_explorer = true;
    experimental_watch_for_changes = true;
  };
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    globals = lib.optionalAttrs cfg-plug.oil.enable {
      netrw_nogx = 1;
    };

    keymaps = lib.optionals cfg-plug.oil.enable [
      {
        mode = "n";
        key = "-";
        action = "<Cmd>Oil<CR>";
        options.desc = "Oil: Open parent directory";
      }
      {
        mode = [ "n" "x" ];
        key = "gx";
        action = "<Cmd>Browse<CR>";
      }
    ];

    extraConfigLua = lib.optionalString cfg-plug.oil.enable /* lua */ ''
      require("gx").setup({
        handler_options = { search_engine = "duckduckgo" },
      })
    '';

    plugins.oil = if nixpkgs-channel == "stable" then
      { extraOptions = settings; }
    else
      { inherit settings; };

    extraPlugins = lib.optional cfg-plug.oil.enable (pkgs.vimUtils.buildVimPlugin {
      name = "gx";
      src = inputs.gx;
    });
  };
}
