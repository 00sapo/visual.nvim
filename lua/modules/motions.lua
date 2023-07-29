local sd = require("modules.serendipity")
local utils = require("modules.utils")
local M = {}

local unpack = unpack or table.unpack

local function iskeyword_pattern()
	local iskeyword = vim.opt_local.iskeyword:get()

	local pattern = "[^"

	for i = 1, #iskeyword do
		if iskeyword[i] ~= "@" then
			-- if iskeyword[i] is like <digits>-<digits>, convert the digits to their
			-- ascii counterpart
			local from, to = string.match(iskeyword[i], "(%d+)-(%d+)")
			if from and to then
				pattern = pattern .. string.char(from) .. "-" .. string.char(to)
			else
				pattern = pattern .. iskeyword[i]
			end
		end
	end

	return pattern .. "]"
end

-- return true if col is at a `direction`-side word boundary in line
-- word here has the same concept as nvim
-- TODO: doesn't take into account iskeyword option
function M.is_word_boundary(pos, direction)
  local kwpattern = iskeyword_pattern()

	local count = 0

	if direction == "r" then
		count = 1
	elseif direction == "l" then
		count = -1
	else
		error('direction must be "r" or "l"')
	end

	local line, col = unpack(pos)

	local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

	-- If the current word has only one character, move to the next word.
	local this_char = line_content:sub(col + 1, col + 1)
	local next_char = line_content:sub(col + 1 + count, col + 1 + count)
	local class1, class2
	if string.match(this_char, "%s") then
		class1 = 1
	elseif string.match(this_char, "%p") and string.match(this_char, kwpattern) then
		class1 = 2
	else
		class1 = 3
	end
	if string.match(next_char, "%s") then
		class2 = 1
	elseif string.match(next_char, "%p") and string.match(this_char, kwpattern) then
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
-- If the current char is at the right-side boundary, moves one word less (like usual
-- `w`)
function M.word_start_next()
	local count1 = vim.v.count1

	-- handle pre-selection stuffs
	if M.is_word_boundary(utils.get_cursor(), "r") then
		if sd.active then
			utils.enter("n")
			vim.api.nvim_feedkeys("w", "n", true)
			-- if after w, we are still at the right-side boundary, this is a
			-- one-char word
			if M.is_word_boundary(utils.get_cursor(), "r") then
				count1 = vim.v.count1 - 1
			end
		elseif vim.v.count1 > 1 then
			count1 = vim.v.count1 - 1
		end
	end

	sd.init()

	-- Move the cursor till the count-th end of word.
	for _ = 1, count1 do
		vim.api.nvim_feedkeys("e", "n", true)
	end
end

return M
