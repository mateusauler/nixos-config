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
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "neovim";
    neovide.enable = lib.mkEnableOption "neovide";
    defaultEditor = pkgs.lib.mkTrueEnableOption "Set neovim as default editor";

    opts = lib.mkOption { default = { }; };

    viAlias      = pkgs.lib.mkTrueEnableOption "Set vi alias";
    vimAlias     = pkgs.lib.mkTrueEnableOption "Set vim alias";
    vimdiffAlias = pkgs.lib.mkTrueEnableOption "Set vimdiff alias";
  };

  imports = [
    ./plugins
  ];

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.neovide.enable pkgs.neovide;

    modules.neovim.opts = {
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

    programs.nixvim = {
      enable = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      } // lib.optionalAttrs cfg.neovide.enable {
        neovide_transparency = 0.8;
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

        (mapNSilent  "<leader>w" "<Cmd>w<CR>" "Save")
        (mapINSilent "<C-S>"     "<Cmd>w<CR>" "Save")
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

      extraConfigVim = /* vim */ ''
        source ${colors}
      '';
    } // (if nixpkgs-channel == "stable" then { options = cfg.opts; } else { inherit (cfg) opts; });

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
