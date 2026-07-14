local M = {}

local floating_panel = require("smart-book-plugin.bookmark-panel")

function M.set_bookmark()
	floating_panel.set_bookmark()
end

function M.toggle_bookmark_panel()
	floating_panel.toggle_floating_panel()
end

return M
