local utils = require("visual.utils")
local Vdbg = require("visual.debugging")
local M = {}
M.options = {
	matches = {
		["("] = { "(", ")" },
		[")"] = { "(", ")" },
		["{"] = { "{", "}" },
		["}"] = { "{", "}" },
		["<"] = { "<", ">" },
		[">"] = { "<", ">" },
		["["] = { "[", "]" },
		["]"] = { "[", "]" },
	},
}

-- given a character, return a list of pairs of characters that can be used for surrounding
function M.get_matching_chars(char)
	local c = M.options.matches[char]
	if c then
		return c
	else
		return { char, char }
	end
end

--- Insert a character at a specific position in the text.
-- @param pos table: A table containing the position information, returned by vim.fn.getpos.
-- @param char string: The character to be inserted.
-- @return nil
function M.insertchar(pos, char)
	vim.api.nvim_buf_set_text(0, pos[2] - 1, pos[3] - 1, pos[2] - 1, pos[3] - 1, { char })
end

--- Delete a character at a specific position in the text.
-- @param pos table: A table containing the position information, returned by vim.fn.getpos.
-- @return nil
function M.deletechar(pos)
	vim.api.nvim_buf_set_text(0, pos[2] - 1, pos[3] - 1, pos[2] - 1, pos[3], { "" })
end

--- Replace a character at a specific position in the text.
-- @param pos table: A table containing the position information, returned by vim.fn.getpos.
-- @param char string: The character to replace with.
-- @return nil
function M.replacechar(pos, char)
	vim.api.nvim_buf_set_text(0, pos[2] - 1, pos[3] - 1, pos[2] - 1, pos[3], { char })
end

local function are_same_line(pos1, pos2)
	return pos1[2] == pos2[2]
end

local function decrement_pos(pos)
	Vdbg("Decrementing column from " .. pos[3])
	pos[3] = pos[3] - 1
	if pos[3] == 0 then
		Vdbg("Column is 0, decrementing line")
		pos[2] = pos[2] - 1
		if pos[2] < 1 then
			Vdbg("Line is " .. pos[2] .. ", going to first buffer character")
			pos[2] = 1
			pos[3] = 1
		else
			-- indexing here is 0-based, so we need to subtract 1
			local line = vim.api.nvim_buf_get_lines(0, pos[2] - 1, pos[2], false)
			if line[1] then
				Vdbg("Going to last column in line " .. pos[2])
				pos[3] = string.len(line[1])
			else
				Vdbg("Line " .. pos[2] .. "is ", line[1])
			end
		end
	end
	return pos
end

-- delete surrounding characters
function M.delete()
	local selection = utils.get_selection()
	local start_pos = selection[1]
	local end_pos = selection[2]
	local first_pos, second_pos = utils.get_ordered_positions(start_pos, end_pos)
	-- the following are inverted because otherwise we would need to update second_pos
	Vdbg("Removing chars at positions ", first_pos, second_pos)
	M.deletechar(second_pos)
	M.deletechar(first_pos)
	-- update selections
	second_pos = decrement_pos(second_pos)
	if are_same_line(first_pos, second_pos) then
		second_pos = decrement_pos(second_pos)
	else
		Vdbg("Detected different lines, avoid decrementing second_pos")
	end

	utils.set_selection({ first_pos, second_pos })
end

-- change surrounding characters according
function M.change()
	local selection = utils.get_selection()
	local start_pos = selection[1] -- a value returned by vim.fn.get_pos
	local end_pos = selection[2] -- a value returned by vim.fn.get_pos
	local first_pos, second_pos = utils.get_ordered_positions(start_pos, end_pos)
	-- wait for character from the user
	local char = string.char(vim.fn.getchar())
	-- lookup the matching pairs
	local char_pair = M.get_matching_chars(char)
	Vdbg("Replacing chars with " .. char_pair[1] .. char_pair[2])
	Vdbg("Replacing chars at positions ", first_pos, second_pos)
	M.replacechar(first_pos, char_pair[1])
	M.replacechar(second_pos, char_pair[2])
	-- reset selection
	utils.set_selection({ first_pos, second_pos })
end

-- add surrounding characters
function M.add()
	local selection = utils.get_selection()
	local start_pos = selection[1]
	local end_pos = selection[2]
	local first_pos, second_pos = utils.get_ordered_positions(start_pos, end_pos)
	-- we actually want to insert a character *after* second_pos
	local line_second_pos = vim.api.nvim_buf_get_lines(0, second_pos[2] - 1, second_pos[2], false)[1]
	local length_second_line = string.len(line_second_pos)
	if second_pos[3] <= length_second_line then
		second_pos[3] = second_pos[3] + 1
	end
	-- wait for character from the user
	local char = string.char(vim.fn.getchar())
	-- lookup the matching pairs
	local char_pair = M.get_matching_chars(char)
	Vdbg("Adding chars with " .. char_pair[1] .. char_pair[2])
	-- the following are inverted because otherwise we sould need to update second_pos
	Vdbg("Insert chars at positions: ", first_pos, second_pos)
	M.insertchar(second_pos, char_pair[2])
	M.insertchar(first_pos, char_pair[1])
	-- update selections
	if are_same_line(first_pos, second_pos) then
		second_pos[3] = second_pos[3] + 1
	else
		Vdbg("Detected different lines, avoid incrementing second_pos")
	end
	-- reset selection
	utils.set_selection({ first_pos, second_pos })
end

return M
