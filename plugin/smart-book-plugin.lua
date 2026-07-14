local smartBook = require("smart-book-plugin")

vim.api.nvim_create_user_command("SmartBookSetBookMark", smartBook.set_bookmark, {})
vim.api.nvim_create_user_command("SmartBookTogglePanel", smartBook.toggle_bookmark_panel, {})
