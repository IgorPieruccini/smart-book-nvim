local M = {}

local tag_panel = require("smart-book-plugin.add-tag-panel")
local util = require("smart-book-plugin.util")

local win_id
local buf

local cur_tag -- current tag

function M.set_add_tag_line(cur_buf)
	vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, {
		"Add new tag",
	})
end

function M.set_tags(cur_buf)
	local content = util.read_content(util.get_state_file_path())
	-- grab all the tags by extracting the root keys from the content table
	local tags = content and vim.tbl_keys(content) or {}

	-- for each tag in tags set the buffer line
	for i, tag in ipairs(tags) do
		vim.api.nvim_buf_set_lines(cur_buf, i, i, false, { tag })
	end
end

function M.go_to_tag_bookmarks(tag, cur_buf)
	local content = util.read_content(util.get_state_file_path())
	local tag_content = content[tag]

	vim.bo[cur_buf].modifiable = true
	vim.bo[cur_buf].readonly = false
	vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, {})
	vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, { "Bookmarks for tag: " .. tag, "<" })

	local row = 2
	for bookmark_name, bookmark in pairs(tag_content or {}) do
		local line_number = bookmark.line_number

		vim.api.nvim_buf_set_lines(
			cur_buf,
			row,
			row,
			false,
			{ row - 1 .. " " .. bookmark_name .. ":" .. tostring(line_number) }
		)
		row = row + 1
	end

	vim.bo[cur_buf].modifiable = false
	vim.bo[cur_buf].readonly = true
	cur_tag = tag
end

function M.open_current_buffer(tag)
	local state_file_path = util.get_state_file_path()
	local content = util.read_content(state_file_path)
	local tag_content = content[tag] or {}

	-- if tag is empty, return
	if tag_content == nil or vim.tbl_isempty(tag_content) then
		print("No saved locations for tag: " .. tag)
		return
	end

	-- for now open the first bookmark of the tag
	local first_key = tag_content and next(tag_content) or nil
	local first_book_mark_content = tag_content[first_key] or {}

	if first_book_mark_content == nil or vim.tbl_isempty(first_book_mark_content) then
		print("bookmark not found")
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(first_book_mark_content.file))
	vim.api.nvim_win_set_cursor(0, { first_book_mark_content.line, first_book_mark_content.col })

	print("Opened saved location")
end

function M.set_win_key_maps(win, cur_buf)
	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(win)
		local row = cursor[1] -- Neovim rows are 1-indexed here
		local line = vim.api.nvim_buf_get_lines(cur_buf, row - 1, row, false)[1]

		if line == "Add new tag" then
			tag_panel.open_floating_panel(win)
			return
		end

		if cur_tag == nil and #line > 5 then
			-- go to bookmark of the tag
			M.go_to_tag_bookmarks(line, cur_buf)
			return
		end

		if cur_tag ~= nil then
			-- open buffer at bookmark
			M.open_current_buffer(cur_tag)
			return
		end
	end, {
		buffer = cur_buf,
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
	buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

	M.set_add_tag_line(buf)
	M.set_tags(buf)

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
