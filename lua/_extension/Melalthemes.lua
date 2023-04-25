-- import deb
local ac_st = require("telescope.actions.state")
local ac = require("telescope.actions")
local pic = require("telescope.pickers")
local fin = require("telescope.finders")
local sor = require("telescope.sorters")
local colors = vim.fn.getcompletion("", "color") -- get all themes
local colorschmefile = "~/.config/nvim/lua/Melal/core/colorscheme.lua"

-- layout config

local lay = {
	layout_strategy = "vertical",
	prompt_title = "󱥚 Set Theme ",
	layout_config = {
		height = 0.9,
		width = 0.5,
		prompt_position = "top",
	},

	sorting_strategy = "ascending",
}

-- when press enter

function enter(prompt_bunfr)
	local sel = ac_st.get_selected_entry() -- get the theme name
	local cmd = "colorscheme " .. sel[1]
	local save = "sed -i '$d' " .. colorschmefile .. " && echo 'vim.cmd([[" .. cmd .. "]])' >> " .. colorschmefile -- delete the last line on colorscheme file and replace

	vim.cmd(cmd)
	vim.fn.jobstart(save) -- for no error
	ac.close(prompt_bunfr)
	vim.notify("theme " .. sel[1] .. " selected")
end

-- reload theme on select

function themepicker_move_prev(prompt_bunfr)
	ac.move_selection_previous(prompt_bunfr)
	local sel = ac_st.get_selected_entry()
	local cmd = "colorscheme " .. sel[1]
	vim.cmd(cmd)
end

function themepicker_move_next(prompt_bunfr)
	ac.move_selection_next(prompt_bunfr)
	local sel = ac_st.get_selected_entry()
	local cmd = "colorscheme " .. sel[1]
	vim.cmd(cmd)
end
----------------------------------

local opts = {
	finder = fin.new_table(colors),
	sorter = sor.get_generic_fuzzy_sorter({}),
	attach_mappings = function(prompt_bunfr, map)
		-- insert mode
		map("i", "<CR>", enter)
		map("i", "<C-j>", themepicker_move_next)
		map("i", "<C-k>", themepicker_move_prev)
		-- normal mode
		map("n", "<CR>", enter)
		map("n", "<C-j>", themepicker_move_next)
		map("n", "<C-k>", themepicker_move_prev)

		return true
	end,
}

local colors = pic.new(lay, opts)

colors:find()
