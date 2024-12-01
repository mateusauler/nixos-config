{ config, lib, ... }:

let
  cfg = config.modules.neovim;
  enabled = config.programs.nixvim.plugins.nvim-ufo.enable;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    opts = {
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    keymaps = lib.optionals enabled [
      {
        mode = "n";
        key = "zR";
        action.__raw = "require('ufo').openAllFolds";
        options.desc = "Open all folds";
      }
      {
        mode = "n";
        key = "zM";
        action.__raw = "require('ufo').closeAllFolds";
        options.desc = "Close all folds";
      }
      {
        mode = "n";
        key = "zK";
        action.__raw = # lua
          ''
            function()
              local winid = require("ufo").peekFoldedLinesUnderCursor()
              if not winid then
                vim.lsp.buf.hover()
              end
            end
          '';
        options.desc = "Peek Fold";
      }
    ];

    plugins.nvim-ufo.settings.provider_selector = # lua
      ''
        function(bufnr, filetype, buftype)
           return { "lsp", "indent" }
         end
      '';
  };
}
