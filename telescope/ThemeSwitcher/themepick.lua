local has_telescope, telescope = pcall(require, "telescope")
local last_selected = nil
-- TODO: make dependency errors occur in a better way
if not has_telescope then
	error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end
-- import deb
local ac_st = require("telescope.actions.state")
local ac = require("telescope.actions")
local pic = require("telescope.pickers")
local fin = require("telescope.finders")
local sor = require("telescope.sorters")
local colors = vim.fn.getcompletion("", "color") -- get all themes
local colorschmefile = "~/.config/nvim/lua/Melal/core/colorscheme.lua"
local conf = require("telescope.config").values

-- layout config

local lay = {
	layout_strategy = "vertical",
	prompt_title = "󱥚 | Set NvMelal Theme ",
	layout_config = {
		height = 0.4,
		width = 0.2,
		prompt_position = "top",
	},

	sorting_strategy = "ascending",
}

local function load_last_selected(prompt_bunfr)
	local f = io.open("/home/melal/.config/nvim/last_selected.txt", "r")
	if f then
		last_selected = f:read("*all")
		f:close()
		vim.cmd("colorscheme " .. last_selected)
		-- vim.notify("The theme " .. last_selected .. " has been selected", "Info", { title = "Theme switcher " })
	end
	ac.close(prompt_bunfr)
end
-- when press enter

function enter(prompt_bunfr)
	local sel = ac_st.get_selected_entry() -- get the theme name
	last_selected = sel[1]
	local f = io.open("/home/melal/.config/nvim/last_selected.txt", "w")
	f:write(last_selected)
	f:close()
	local cmd = "colorscheme " .. sel[1]

	local save = "sed -i '$d' " .. colorschmefile .. " && echo 'vim.cmd([[" .. cmd .. "]])' >> " .. colorschmefile -- delete the last line on colorscheme file and replace

	vim.cmd(cmd)
	vim.fn.jobstart(save) -- for no error
	ac.close(prompt_bunfr)
	vim.notify("The theme " .. sel[1] .. " has been selected", "Info", { title = "Theme switcher " })
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
		map("i", "<C-d>", load_last_selected)
		map("i", "<C-j>", themepicker_move_next)
		map("i", "<C-k>", themepicker_move_prev)
		-- normal mode
		map("n", "<CR>", enter)
		map("n", "<C-j>", themepicker_move_next)
		map("n", "<C-k>", themepicker_move_prev)

		return true
	end,
	on_close = function(prompt_bufnr)
		local sel = ac_st.get_selected_entry()
		if sel == nil and last_selected ~= nil then
			-- no selection made, use last selected theme as default
			vim.cmd("colorscheme " .. last_selected)
			vim.notify("The theme " .. last_selected .. " has been selected", "Info", { title = "Theme switcher " })
		end
	end,
}

local switcher = pic.new(lay, opts):find()
