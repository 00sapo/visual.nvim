local dbg = false

local window = nil
local buffer = nil

local heap = {}

local function write()
	if dbg then
		-- Check if buffer is not initialized
		if buffer == nil then
			-- Set the buffer to the `buffer` variable
			buffer = vim.api.nvim_create_buf(false, true)
			-- Create a window at the bottom
			window = vim.api.nvim_open_win(
				buffer,
				false,
				{ relative = "editor", width = 150, height = 20, col = 12, row = 23 }
			)
		end
		-- Append the lines to the bottom of the buffer
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, heap)
		-- scroll the window to the bottom
		vim.api.nvim_win_set_cursor(window, { vim.api.nvim_buf_line_count(buffer), 0 })
	end
end

-- mapping the write function
if dbg then
  vim.api.nvim_create_user_command('Debug', write, {})
  vim.keymap.set({"n", "v", "i"}, "<c-s-d>", write, {nowait=true})
end

--- Function to debug and log serialized string to a buffer
-- @param x: The data to be serialized and logged
-- @return nil
return function(...)
	-- Check if debug mode is enabled
	if dbg then
		-- Serialize the input data
		local serialized_x = ""
		for _, v in ipairs({ ... }) do
			serialized_x = serialized_x .. vim.inspect(v)
		end
		-- Split the serialized string into lines
		for s in serialized_x:gmatch("[^\r\n]+") do
			table.insert(heap, s)
		end
	end
end
