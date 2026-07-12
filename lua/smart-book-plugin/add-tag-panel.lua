local M = {}

local util = require("smart-book-plugin.util")

local win_id
local return_win_id

function M.submit_tag()
	local line = vim.trim(vim.api.nvim_get_current_line())

	-- if line does not have more than 5 characters, alert the user and return
	if #line < 5 then
		vim.notify("Tag must be at least 5 characters long", vim.log.levels.ERROR)
		return
	end

	util.add_new_tag(line)
	vim.notify("new tag: " .. line)
	vim.cmd("stopinsert")
	M.close_floating_panel()
end

function M.set_confirmation_key_map(win, buf)
	vim.keymap.set("i", "<CR>", M.submit_tag, {
		buffer = buf,
		desc = "Add new tag",
	})
end

function M.set_close_key_map()
	vim.keymap.set("n", "q", function()
		M.close_floating_panel()
	end, {
		desc = "Close add tag panel",
	})
end

function M.close_floating_panel()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end
	win_id = nil

	local target_win = return_win_id
	return_win_id = nil

	if target_win and vim.api.nvim_win_is_valid(target_win) then
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(target_win) then
				vim.api.nvim_set_current_win(target_win)
			end
		end)
	end
end

function M.open_floating_panel(previous_win)
	return_win_id = previous_win

	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

	local width = math.floor(vim.o.columns * 0.2)
	local height = 1
	local row = 1
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

	M.set_confirmation_key_map(win_id, buf)
	M.set_close_key_map()
	vim.cmd("startinsert") -- Start in insert mode
end

return M
