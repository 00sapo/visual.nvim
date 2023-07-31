local dbg = true

local window = nil
local buffer = nil

--- Function to debug and log serialized string to a buffer
-- @param x: The data to be serialized and logged
-- @return nil
return function(...)
	-- Check if debug mode is enabled
	if dbg then
		-- Check if buffer is not initialized
		if buffer == nil then
			-- Set the buffer to the `buffer` variable
			buffer = vim.api.nvim_create_buf(true, true)
			print("hello " .. buffer)
			-- Create a window at the bottom
			window = vim.api.nvim_open_win(
				buffer,
				false,
				{ relative = "editor", width = 150, height = 20, col = 12, row = 23 }
			)
		end
		-- Serialize the input data
		local serialized_x = ""
		for _, v in ipairs({...}) do
		    serialized_x = serialized_x .. vim.inspect(v)
		end
		-- Split the serialized string into lines
		local lines = {}
		for s in serialized_x:gmatch("[^\r\n]+") do
		    table.insert(lines, s)
		end
		-- Append the lines to the bottom of the buffer
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, lines)
		-- scroll the window to the bottom
		vim.api.nvim_win_set_cursor(window, { vim.api.nvim_buf_line_count(buffer), 0 })
	end
end
