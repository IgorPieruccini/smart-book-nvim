local M = {}

function M.normalize_string(str)
	-- Replace spaces with underscores
	str = str:gsub("%s+", "_")
	-- Remove special characters
	str = str:gsub("[^%w_]", "")
	-- Convert to lowercase
	return str:lower()
end

function M.get_root()
	local root = vim.fs.root(0, ".git")
	if root == nil then
		root = vim.fn.getcwd()
	end

	return root
end

function M.get_normalized_root()
	return M.normalize_string(M.get_root())
end

function M.get_state_file_path()
	return vim.fs.joinpath(vim.fn.stdpath("state"), M.get_normalized_root() .. "-smartbook-location.json")
end

function M.read_state_file(state_file_path)
	if vim.fn.filereadable(state_file_path) == 0 then
		print("State file does not exist: " .. state_file_path)
	end

	local lines = vim.fn.readfile(state_file_path)
	if #lines == 0 then
		print("State file is empty" .. state_file_path)
	end

	local file = assert(io.open(state_file_path, "r"))
	local content = file:read("*a")
	file:close()

	return vim.json.decode(content)
end

function M.create_state_file(state_file_path)
	if vim.fn.filereadable(state_file_path) == 0 then
		local file = io.open(state_file_path, "w")
		if file then
			file:write("{}")
			file:close()
		else
			print("Error creating state file: " .. state_file_path)
		end
	end
end

function M.write_state_file(state_file_path, content)
	local file = io.open(state_file_path, "w")
	if file then
		file:write(vim.json.encode(content))
		file:close()
	else
		print("Error writing to state file: " .. state_file_path)
	end
end

function M.read_content(state_file_path)
	M.create_state_file(state_file_path)
	return M.read_state_file(state_file_path)
end

function M.add_new_tag(tag)
	local state_file_path = M.get_state_file_path()
	local content = M.read_state_file(state_file_path)
	-- Force an object shape so JSON encodes the tag as "{}" instead of "[]".
	content[tag] = vim.empty_dict()

	M.write_state_file(state_file_path, content)
end

return M
