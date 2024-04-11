{ config, lib, ... }:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
    extraConfigLua = lib.optionalString cfg-plug.neo-tree.enable /* lua */ ''
      vim.fn.sign_define("DiagnosticSignError", {text = " ", texthl = "DiagnosticSignError"})
      vim.fn.sign_define("DiagnosticSignWarn",  {text = " ", texthl = "DiagnosticSignWarn"})
      vim.fn.sign_define("DiagnosticSignInfo",  {text = " ", texthl = "DiagnosticSignInfo"})
      vim.fn.sign_define("DiagnosticSignHint",  {text = "󰌵 ", texthl = "DiagnosticSignHint"})
    '';

    keymaps = lib.optionals cfg-plug.neo-tree.enable [
      {
        mode = "n";
        key = "<leader>e";
        action = "<Cmd>Neotree toggle<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-E>";
        action = "<Cmd>Neotree toggle<CR>";
        options.silent = true;
      }
    ];

    plugins.neo-tree = {
      closeIfLastWindow = true;
      documentSymbols.followCursor = true;
      logLevel = "warn";
      popupBorderStyle = "rounded";
      sortCaseInsensitive = true;

      buffers = {
        followCurrentFile = {
          enabled = true;
          leaveDirsOpen = true;
        };
        groupEmptyDirs = true;
      };

      eventHandlers.file_opened  = /* lua */ ''
        function(file_path)
          require("neo-tree.command").execute({ action = "close" })
        end
      '';

      filesystem = {
        scanMode = "deep";
        groupEmptyDirs = true;
        followCurrentFile = {
          enabled = true;
          leaveDirsOpen = true;
        };
      };

      gitStatus.window.mappings.g = {
        command = "show_help";
        nowait = false;
        config = { title = "Git"; prefix_key = "g"; };
      };

      sourceSelector = {
        winbar = true;
        showScrolledOffParentNode = true;
        contentLayout = "focus";
      };

      window = {
        popup.size.width = "80%";
        mappings = {
          "<space>" = { command = "toggle_node";   nowait = false; };
          "a" =       { command = "add";           config.show_path = "relative"; };
          "A" =       { command = "add_directory"; config.show_path = "relative"; };
          "c" =       { command = "copy";          config.show_path = "relative"; };
          "m" =       { command = "move";          config.show_path = "relative"; };
        };
      };
    };
  };
}
