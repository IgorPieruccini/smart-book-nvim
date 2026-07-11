local smartBook = require("smart-book-plugin")

vim.api.nvim_create_user_command("SmartBookCurrentLocation", smartBook.get_current_location, {})
vim.api.nvim_create_user_command("SmartBookMarkedBuffer", smartBook.open_current_buffer, {})
vim.api.nvim_create_user_command("SmartBookTogglePanel", smartBook.toggle_bookmark_panel, {})
