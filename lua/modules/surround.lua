local utils = require("modules.utils")
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
	pos[3] = pos[3] - 1
	if pos[3] == 0 then
		pos[2] = pos[2] - 1
		if pos[2] < 1 then
			pos[2] = 1
			pos[3] = 1
		else
			local line = vim.api.nvim_buf_get_lines(0, pos[2], pos[2] - 1, false)
			pos[3] = string.len(line[1])
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
	M.deletechar(second_pos)
	M.deletechar(first_pos)
	-- update selections
  second_pos = decrement_pos(decrement_pos(second_pos))
  first_pos = decrement_pos(first_pos)
	if are_same_line(first_pos, second_pos) then
		second_pos = decrement_pos(second_pos)
	end

	utils.set_selection({first_pos, second_pos})
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
	-- replace char_pair at start_pos and end_pos
	M.replacechar(first_pos, char_pair[1])
	M.replacechar(second_pos, char_pair[2])
	-- reset selection
	utils.set_selection({first_pos, second_pos})
end

-- add surrounding characters
function M.add()
	local selection = utils.get_selection()
	local start_pos = selection[1]
	local end_pos = selection[2]
	local first_pos, second_pos = utils.get_ordered_positions(start_pos, end_pos)
	-- we actually want to insert a character *after* second_pos
	second_pos[3] = second_pos[3] + 1
	-- wait for character from the user
	local char = string.char(vim.fn.getchar())
	-- lookup the matching pairs
	local char_pair = M.get_matching_chars(char)
	-- the following are inverted because otherwise we sould need to update second_pos
	M.insertchar(second_pos, char_pair[2])
	M.insertchar(first_pos, char_pair[1])
	-- update selections
  first_pos = decrement_pos(first_pos)
	if not are_same_line(first_pos, second_pos) then
    second_pos = decrement_pos(second_pos)
	end
	-- reset selection
	utils.set_selection({first_pos, second_pos})
end

return M
