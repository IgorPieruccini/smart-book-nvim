local M = {}

local win_id

function M.open_floating_panel()
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

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
