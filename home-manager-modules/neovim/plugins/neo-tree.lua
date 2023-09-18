vim.fn.sign_define("DiagnosticSignError", {text = " ", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text = " ", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo",  {text = " ", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint",  {text = "󰌵 ", texthl = "DiagnosticSignHint"})

local config = {
  log_level = "warn",
  popup_border_style = "rounded",
  sort_case_insensitive = true,

  -- source_selector provides clickable tabs to switch between sources.
  source_selector = {
    winbar = true,
    show_scrolled_off_parent_node = true,
    content_layout = "center",
  },

  event_handlers = {
    {
      event = "file_opened",
      handler = function(file_path)
        --auto close
        require("neo-tree.command").execute({ action = "close" })
      end
    },
  },
  default_component_configs = {
    diagnostics = {
      highlights = {
        hint = "DiagnosticSignHint",
        info = "DiagnosticSignInfo",
        warn = "DiagnosticSignWarn",
        error = "DiagnosticSignError",
      },
    },
    indent = { with_markers = false },
  },
  -- Global custom commands that will be available in all sources (if not overridden in `opts[source_name].commands`)
  --
  -- You can then reference the custom command by adding a mapping to it:
  --    globally    -> `opts.window.mappings`
  --    locally     -> `opt[source_name].window.mappings` to make it source specific.
  --
  -- commands = {              |  window {                 |  filesystem {
  --   hello = function()      |    mappings = {           |    commands = {
  --     print("Hello world")  |      ["<C-c>"] = "hello"  |      hello = function()
  --   end                     |    }                      |        print("Hello world in filesystem")
  -- }                         |  }                        |      end
  --
  -- see `:h neo-tree-custom-commands-global`
  -- TODO: Add a focus swap command
  commands = {}, -- A list of functions

  window = {
    popup = { size = { width = "80%" } },
    mappings = {
      ["<space>"] = "toggle_node",
      ["a"] = { "add",           config = { show_path = "relative" } },
      ["A"] = { "add_directory", config = { show_path = "relative" } },
      ["c"] = { "copy", config = { show_path = "relative" } },
      ["m"] = { "move", config = { show_path = "relative" } },
    },
  },
  filesystem = {
    scan_mode = "deep",
    group_empty_dirs = true,
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
  },
  buffers = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
    group_empty_dirs = true,
    show_unloaded = true,
  },
  git_status = { window = { mappings = { ["g"] = { "show_help", nowait=false, config = { title = "Git", prefix_key = "g" } } } } },
  document_symbols = { follow_cursor = true },
}

require('neo-tree').setup(config)
vim.cmd([[nnoremap <leader>e :Neotree reveal<cr>]])
