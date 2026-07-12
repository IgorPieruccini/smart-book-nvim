local M = {}

local util = require("smart-book-plugin.util")

local tag = "development"
local state_file_path = util.get_state_file_path()

function M.get_current_location()
	local data = {
		file = vim.api.nvim_buf_get_name(0),
		line = vim.api.nvim_win_get_cursor(0)[1],
		col = vim.api.nvim_win_get_cursor(0)[2],
	}

	-- Read the state_file content, and guarantee that tag exist
	local content = util.read_content(state_file_path)
	local tag_content = content[tag] or {}

	-- get the last dir + file to create a unique key for the file, and append line and column to it
	local file_name = data.file:match("([^/]+)$")
	file_name = file_name or data.file

	local last_dir = data.file:match("([^/]+)/[^/]+$")
	if last_dir ~= nil then
		file_name = last_dir .. "/" .. file_name
	end

	file_name = file_name .. ":" .. data.line .. ":" .. data.col

	local key = file_name
	local updated_content = vim.tbl_extend("force", tag_content, { [key] = data })

	local new_content = vim.tbl_extend("force", content, { [tag] = updated_content })

	util.write_state_file(state_file_path, new_content)

	print("New smart book:" .. key)
end

function M.toggle_bookmark_panel()
	local floating_panel = require("smart-book-plugin.bookmark-panel")
	floating_panel.toggle_floating_panel()
end

return M
