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
	dashboard.button("n", "󰈔 New file", ":enew<CR>"),
	dashboard.button("e", " Explore",  ":Explore<CR>")
}
if dotscloned then
	table.insert(dashboard.section.buttons.val, dashboard.button("c", " Nix config flake" , ":cd " .. dotspath .. " | :e .<CR>"))
end
table.insert(dashboard.section.buttons.val, dashboard.button("q", "󰅙 Quit nvim", ":qa<CR>"))

alpha.setup(dashboard.opts)
vim.keymap.set("n", "<leader>h", ":Alpha<CR>", { silent = true, desc = "Open alpha dashboard" })
