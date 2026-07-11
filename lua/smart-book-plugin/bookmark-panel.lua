local M = {}

local util = require("smart-book-plugin.util")

local win_id

function M.set_add_tag_line(buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"Add new tag",
	})
end

function M.set_win_key_maps(win, buf)
	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local row = cursor[1] -- Neovim rows are 1-indexed here
		local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
		if line == "Add new tag" then
			util.add_new_tag()
			vim.notify("add tag")
		end
	end, {
		buffer = buf,
		desc = "Add new tag",
	})
end

function M.set_close_key_map()
	vim.keymap.set("n", "q", function()
		M.close_floating_panel()
	end, {
		desc = "Close smart book panel",
	})
end

function M.open_floating_panel()
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

	M.set_add_tag_line(buf)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	win_id = vim.api.nvim_open_win(buf, true, opts) -- Open a floating window with the buffer
	M.set_win_key_maps(win_id, buf)
	M.set_close_key_map()

	-- Prevent user from modifying the buffer
	vim.bo[buf].modifiable = false
	vim.bo[buf].readonly = true
end

function M.close_floating_panel()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end
	win_id = nil
end

function M.toggle_floating_panel()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		M.close_floating_panel()
	else
		M.open_floating_panel()
	end
end

return M
