{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovim;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    extraConfigLua = /* lua */ ''
      vim.api.nvim_set_hl(0, 'EyelinerPrimary',   { bold = true, underline = true })
      vim.api.nvim_set_hl(0, 'EyelinerSecondary', { bold = true })
      require('eyeliner').setup({ highlight_on_key = true })
    '';

    extraPlugins = [
      pkgs.vimPlugins.eyeliner-nvim
    ];
  };
}
