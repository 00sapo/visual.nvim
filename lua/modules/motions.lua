local utils = require("modules.utils")
local M = {}

local unpack = unpack or table.unpack

-- return true if col is at a `direction`-side word boundary in line
-- word here has the same concept as nvim 
-- TODO: doesn't take into account iskeyword option
function M.is_word_boundary(line, col, direction)
	local count = 0

	if direction == "r" then
		count = 1
	elseif direction == "l" then
		count = -1
	else
		error('direction must be "r" or "l"')
	end

	local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

	-- If the current word has only one character, move to the next word.
	local this_char = line_content:sub(col + 1, col + 1)
	local next_char = line_content:sub(col + 1 + count, col + 1 + count)
	local class1, class2
	if string.match(this_char, "%s") then
		class1 = 1
  elseif  string.match(this_char, "%p") then
    class1 = 2
	else
		class1 = 3
	end
	if string.match(next_char, "%s") then
		class2 = 1
  elseif  string.match(next_char, "%p") then
    class2 = 2
	else
		class2 = 3
	end
	local end_of_line = false
	if col + 1 == #line_content or #line_content == 0 then
		end_of_line = true
	end
	local start_of_line = false
	if col == 0 or #line_content == 0 then
		start_of_line = true
	end

	if class1 ~= class2 or (end_of_line and direction == "r") or (start_of_line and direction == "l") then
		return true
	else
		return false
	end
end

--- Move the cursor to the vim.v.count1-th end of word.
-- If the current char is at the right-side boundary, doesn't move.
function M.end_word()
	vim.api.nvim_feedkeys("", "x", true)
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))

	if M.is_word_boundary(line, col, "r") then
    if vim.v.count1 > 1 then
      vim.v.count1 = vim.v.count1 - 1
    else
      return
    end
	end

	-- Move the cursor till the count-th end of word.
	for _ = 1, vim.v.count1 do
		vim.api.nvim_feedkeys("e", "n", true)
	end
end

-- Move the cursor to the next start of word (no vim.v.count1)
-- If the current char is not at the right-side boundary, doesn't move.
function M.start_word_next()
	vim.api.nvim_feedkeys("", "x", true)
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))

	if M.is_word_boundary(line, col, "r") then
		vim.api.nvim_feedkeys("w", "n", true)
	else
		return
	end
end

return M
