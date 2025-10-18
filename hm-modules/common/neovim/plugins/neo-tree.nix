{
  config,
  lib,
  nixpkgs-channel,
  ...
}:

let
  cfg = config.modules.neovim;
  cfg-plug = config.programs.nixvim.plugins;
in
lib.mkIf cfg.enable {
  programs.nixvim = {
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

    plugins.neo-tree =
      if nixpkgs-channel == "unstable" then
        {
          settings = {
            close_if_last_window = true;
            document_symbols.follow_cursor = true;
            log_level = "warn";
            popup_border_style = "rounded";
            sort_case_insensitive = true;

            buffers = {
              follow_current_file = {
                enabled = true;
                leave_dirs_open = true;
              };
              group_empty_dirs = true;
            };

            event_handlers.file_opened = # lua
              ''
                function(file_path)
                  require("neo-tree.command").execute({ action = "close" })
                end
              '';

            filesystem = {
              scan_mode = "deep";
              group_empty_dirs = true;
              follow_current_file = {
                enabled = true;
                leave_dirs_open = true;
              };
            };

            git_status.window.mappings.g = {
              command = "show_help";
              nowait = false;
              config = {
                title = "Git";
                prefix_key = "g";
              };
            };

            source_selector = {
              winbar = true;
              show_scrolled_off_parent_node = true;
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
        }
      else
        {
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

          eventHandlers.file_opened = # lua
            ''
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
            config = {
              title = "Git";
              prefix_key = "g";
            };
          };

          sourceSelector = {
            winbar = true;
            showScrolledOffParentNode = true;
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
