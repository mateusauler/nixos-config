{ config, lib, ... }:

let
  cfg = config.modules.neovim;
  enabled = config.programs.nixvim.plugins.nvim-ufo.enable;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    globals = lib.optionalAttrs enabled {
      foldcolumn = 1;
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    keymaps = lib.optionals enabled [
      {
        mode = "n";
        key = "zR";
        action = "require('ufo').openAllFolds";
        options.desc = "Open all folds";
        lua = true;
      }
      {
        mode = "n";
        key = "zM";
        action = "require('ufo').closeAllFolds";
        options.desc = "Close all folds";
        lua = true;
      }
      {
        mode = "n";
        key = "zK";
        action = /* lua */ ''
          function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then
              vim.lsp.buf.hover()
            end
          end
        '';
        options.desc = "Peek Fold";
        lua = true;
      }
    ];

    plugins.nvim-ufo.providerSelector = /* lua */ ''
     function(bufnr, filetype, buftype)
        return { "lsp", "indent" }
      end
    '';
  };
}
