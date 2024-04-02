{ config, lib, nixpkgs-channel, osConfig, pkgs, ... }:

let
  cfg = config.modules.neovim;
  colors = pkgs.writeText "colors.vim" (import ./colors.nix config.colorScheme);

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
  } // lib.optionalAttrs cfg.neovide.enable {
    guifont = with osConfig.defaultFonts.mono; "${name}:h${toString size}";
  };
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "neovim";
    neovide.enable = lib.mkEnableOption "neovide";
    defaultEditor = pkgs.lib.mkTrueEnableOption "Set neovim as default editor";

    viAlias      = pkgs.lib.mkTrueEnableOption "Set vi alias";
    vimAlias     = pkgs.lib.mkTrueEnableOption "Set vim alias";
    vimdiffAlias = pkgs.lib.mkTrueEnableOption "Set vimdiff alias";
  };

  imports = [
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.neovide.enable pkgs.neovide;

    programs.nixvim = {
      enable = true;

      options = opts;

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
          command = /* vim */ "setlocal tabstop=2 expandtab";
        }
      ];

      keymaps = lib.flatten [
        { key = ";"; action = ":"; options.desc = "Command"; }

        (mapNSilent  "<leader>w" ":w<CR>" "Save")
        (mapINSilent "<C-S>"     ":w<CR>" "Save")
        (mapNSilent  "<leader>q" ":q<CR>" "Quit")
        (mapINSilent "<C-Q>"     ":q<CR>" "Quit")

        # Common shortcuts
        (mapISilent  "<C-V>"   "p"         "Paste from clipboard")
        (mapINSilent "<C-Z>"   ":undo<CR>" "Undo last action")
        (mapINSilent "<C-S-Z>" ":redo<CR>" "Redo last undone action")

        (mapISilent "<C-BS>" "vbd" "Delete previous word")

        # Buffer commands
        (mapNSilent  "<leader>c" ":bd<CR>" "Close buffer")
        (mapINSilent "<C-Tab>"   ":bn<CR>" "Next buffer")
        (mapINSilent "<A-l>"     ":bn<CR>" "Next buffer")
        (mapINSilent "<C-S-Tab>" ":bp<CR>" "Previous buffer")
        (mapINSilent "<A-h>"     ":bp<CR>" "Previous buffer")

        # Split
        (mapNSilent "<C-|>"  ":split<CR>" "Horizontal split")
        (mapNSilent "<C-\\>" ":vsplit<CR>" "Vertical split")
        # Movement
        (mapNSilent "<C-K>" ":wincmd k<CR>" "Move to split above")
        (mapNSilent "<C-J>" ":wincmd j<CR>" "Move to split below")
        (mapNSilent "<C-H>" ":wincmd h<CR>" "Move to split left")
        (mapNSilent "<C-L>" ":wincmd l<CR>" "Move to split right")
      ];

      extraConfigVim = /* vim */ ''
        source ${colors}
      '';

      extraConfigLua = /* lua */ ''
        ${builtins.readFile ./plugins/neo-tree.lua}
      '';
    };

    home.sessionVariables = lib.mkIf cfg.defaultEditor {
      EDITOR = lib.mkDefault "nvim";
      VISUAL = lib.mkDefault "nvim";
    };

    shell-aliases =
      lib.foldl'
        (acc: n: acc // { ${n} = "nvim"; })
        { }
        (lib.filter
          (n: cfg."${n}Alias")
          [ "vi" "vim" "vimdiff" ]
        );

    # Re-source the config on running nvim instances
    xdg.configFile."nvim/init.lua".onChange = /* bash */ ''
      XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      for server in $XDG_RUNTIME_DIR/nvim.*; do
        $DRY_RUN_CMD ${lib.getExe pkgs.neovim} --server $server --remote-send '<Esc>:source ${config.xdg.configHome}/nvim/init.lua<CR>' &
      done
    '';
  };
}
