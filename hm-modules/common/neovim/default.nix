{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.neovim;

  mapSilent = mode: key: action: desc: {
    inherit key action mode;
    options = {
      inherit desc;
      silent = true;
    };
  };

  mapISilent = key: action: mapSilent "i" key "<Esc>${action}a";
  mapNSilent = mapSilent "n";
  mapINSilent = key: action: desc: [
    (mapISilent key action desc)
    (mapNSilent key action desc)
  ];
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "neovim";
    neovide.enable = lib.mkEnableOption "neovide";

    viAlias  = pkgs.lib.mkTrueEnableOption "Set vi alias";
    vimAlias = pkgs.lib.mkTrueEnableOption "Set vim alias";
  };

  imports = [
    ./neovide.nix
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      vimdiffAlias = true;

      opts = {
        # Line numbers
        number = true;
        relativenumber = true;

        # Tabs
        tabstop = 4;     # 4 char-wide tab
        softtabstop = 0; # Use same length as 'tabstop'
        shiftwidth = 0;  # Use same length as 'tabstop'

        updatetime = 300;

        termguicolors = true;
        signcolumn = "yes";

        mouse = "a";

        ignorecase = true;
        smartcase = true;
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      # Use system clipboard
      clipboard.register = "unnamedplus";

      autoCmd = [
        # 2 char-wide overrides
        {
          event = "FileType";
          pattern = "nix";
          command = # vim
            ''
              setlocal tabstop=2 expandtab
            '';
        }
      ];

      keymaps = lib.flatten [
        (mapNSilent  "<leader>w" "<Cmd>w<CR>" "Save")
        (mapNSilent  "<leader>q" "<Cmd>q<CR>" "Quit")
        (mapINSilent "<C-Q>"     "<Cmd>q<CR>" "Quit")

        # Common shortcuts
        (mapISilent  "<C-V>"   "p"             "Paste from clipboard")
        (mapINSilent "<C-Z>"   "<Cmd>undo<CR>" "Undo last action")
        (mapINSilent "<C-S-Z>" "<Cmd>redo<CR>" "Redo last undone action")

        (mapISilent "<C-BS>" "vbd" "Delete previous word")

        # Buffer commands
        (mapNSilent  "<leader>c" "<Cmd>bd<CR>" "Close buffer")
        (mapINSilent "<C-Tab>"   "<Cmd>bn<CR>" "Next buffer")
        (mapINSilent "<A-l>"     "<Cmd>bn<CR>" "Next buffer")
        (mapINSilent "<C-S-Tab>" "<Cmd>bp<CR>" "Previous buffer")
        (mapINSilent "<A-h>"     "<Cmd>bp<CR>" "Previous buffer")

        # Split
        (mapNSilent "<C-|>"  "<Cmd>split<CR>"  "Horizontal split")
        (mapNSilent "<C-\\>" "<Cmd>vsplit<CR>" "Vertical split")
        # Movement
        (mapNSilent "<C-K>" "<Cmd>wincmd k<CR>" "Move to split above")
        (mapNSilent "<C-J>" "<Cmd>wincmd j<CR>" "Move to split below")
        (mapNSilent "<C-H>" "<Cmd>wincmd h<CR>" "Move to split left")
        (mapNSilent "<C-L>" "<Cmd>wincmd l<CR>" "Move to split right")

        (mapNSilent "<leader>h" "<Cmd>noh<CR>" "Clear highlighting")
      ];

      diagnostic.settings = {
        virtual_text = false;
        virtual_lines.current_line = true;
        signs.text =
          config.lib.nixvim.mkRaw # lua
            ''
              {
                [vim.diagnostic.severity.ERROR] = ' ',
                [vim.diagnostic.severity.WARN]  = ' ',
                [vim.diagnostic.severity.INFO]  = ' ',
                [vim.diagnostic.severity.HINT]  = '󰌵 ',
              }
            '';
      };
    };

    shell-aliases = {
      vi  = lib.mkIf cfg.viAlias  "nvim";
      vim = lib.mkIf cfg.vimAlias "nvim";
    };

    programs.fish.shellAbbrs = {
      n = "nvim";
      ni = lib.mkIf cfg.neovide.enable "neovide";
    };

    # Re-source the config on running nvim instances
    xdg.configFile."nvim/init.lua".onChange = # bash
      ''
        XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
        for server in $XDG_RUNTIME_DIR/nvim.*; do
          $DRY_RUN_CMD ${lib.getExe pkgs.neovim} --server $server --remote-send '<Esc>:source ${config.xdg.configHome}/nvim/init.lua<CR>' &
        done
      '';
  };
}
