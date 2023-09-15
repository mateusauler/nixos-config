{ config, lib, nix-colors, pkgs, ... }:

let
  cfg = config.modules.neovim;
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      extraConfig = ''
        " Use system clipboard
        set clipboard=unnamedplus

        " Line numbers
        set number
        set relativenumber

        " Tabs
        set tabstop=4 " 4 char-wide tab
        set softtabstop=0 " Use same length as 'tabstop'
        set shiftwidth=0  " Use same length as 'tabstop'

        " 2 char-wide overrides
        augroup two_space_tab
          autocmd!
          autocmd FileType nix setlocal tabstop=2 expandtab
        augroup END
      '';
      plugins = with pkgs.vimPlugins; [
        vim-nix
        nvim-treesitter.withAllGrammars
        {
          plugin = nix-colors-lib.vimThemeFromScheme { scheme = config.colorScheme; };
          config = "colorscheme nix-${config.colorScheme.slug}";
        }
      ];
    };
  };
}
