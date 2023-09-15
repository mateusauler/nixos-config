local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
  "                                                     ",
}
dashboard.section.header.opts.hl = "Title"

dashboard.section.buttons.val = {
  dashboard.button( "n", "󰈔 New file",          ":enew<CR>"),
  dashboard.button( "e", " Explore",           ":Explore<CR>"),
  dashboard.button( "c", " Nix config flake" , ":cd " .. dotspath .. " | :e .<CR>"),
  dashboard.button( "q", "󰅙 Quit nvim",         ":qa<CR>"),
}

alpha.setup(dashboard.opts)
vim.keymap.set("n", "<space>a", ":Alpha<CR>", { desc = "Open alpha dashboard" })