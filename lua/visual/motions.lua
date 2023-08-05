local sd = require("visual.serendipity")
local utils = require("visual.utils")
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

-- * return true if col is at a `direction`-side word boundary in line
-- * word here has the same concept as nvim
-- * if `punctuation` is true, then word punctuation create words by themselves (as
-- in w), otherwise it's like W
function M.is_word_boundary(pos, direction, punctuation)
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
	elseif punctuation and string.match(this_char, "%p") and string.match(this_char, kwpattern) then
		class1 = 2
	else
		class1 = 3
	end
	if string.match(next_char, "%s") then
		class2 = 1
	elseif punctuation and string.match(next_char, "%p") and string.match(next_char, kwpattern) then
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
    Vdbg("detected word boundary with " .. direction .. " and " .. tostring(punctuation))
    Vdbg("class1: " .. class1, "class2: " .. class2, end_of_line, start_of_line)
		return true
	else
    Vdbg("not detected word boundary with " .. direction .. " and " .. tostring(punctuation))
    Vdbg("class1: " .. class1, "class2: " .. class2, end_of_line, start_of_line)
		return false
	end
end

--- Move the cursor to the vim.v.count1-th end of word.
-- If the current char is at the right-side boundary, moves one word less (like usual
-- `w`)
function M.word_start_next()
	M.word_motion(true, "r")
end

function M.word_start_prev()
	M.word_motion(true, "l")
end

function M.WORD_start_next()
	M.word_motion(false, "r")
end

function M.WORD_start_prev()
	M.word_motion(false, "l")
end

local function check_side(direction)
  local s = utils.get_selection()
  if direction == "r" then
    return s[2][2] > s[1][2] or (s[2][3] > s[1][3] and s[2][2] == s[1][2])
  elseif direction == "l" then
    return s[2][2] < s[1][2] or (s[2][3] < s[1][3] and s[2][2] == s[1][2])
  end
end

function M.word_motion(punctuation, side)
	local count1 = vim.v.count1

	-- choosing actions
	local w, e
	if side == "r" and punctuation then
		w = "w"
		e = "e"
	elseif side == "l" and punctuation then
		w = "ge"
		e = "b"
	elseif side == "r" and not punctuation then
		w = "W"
		e = "E"
	elseif side == "l" and not punctuation then
		w = "gE"
		e = "B"
	end

	-- if we are not at proper side, change it
	local boundary = M.is_word_boundary(utils.get_cursor(), side, punctuation)
	if sd.active and not boundary then
    -- if the cursor is not on the side `side`
    if not check_side(side) then
			Vdbg("o")
			vim.api.nvim_feedkeys("o", "n", true)
			boundary = M.is_word_boundary(utils.get_cursor(), side, punctuation)
		end
	end

	-- handle pre-selection stuffs
	if boundary then
		if sd.active then
			Vdbg("<esc>")
			utils.enter("n")
			Vdbg(w)
			vim.api.nvim_feedkeys(w, "n", true)
			-- if after w, we are still at the right-side boundary, this is a
			-- one-char word
			if M.is_word_boundary(utils.get_cursor(), side, punctuation) then
				Vdbg("c-1")
				count1 = vim.v.count1 - 1
			end
		elseif vim.v.count1 > 1 then
			Vdbg("c-1")
			count1 = vim.v.count1 - 1
		end
	end

	if sd.active then
		Vdbg("<esc>")
		utils.enter("n")
		vim.api.nvim_feedkeys("", "x", true)
	end
	Vdbg("<sdi>")
	sd.init()

	-- Move the cursor till the count-th end of word.
	for _ = 1, count1 do
		Vdbg(e)
		vim.api.nvim_feedkeys(e, "n", true)
	end

	Vdbg("o")
	vim.api.nvim_feedkeys("o", "n", true)
end

return M
