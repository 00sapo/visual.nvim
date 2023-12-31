local keys_amend = require("visual.keymap-amend")
local Vdbg = require("visual.debugging")

local utils = {}

-- return a function that feeds keys to vim, ask for some argument, feed the argument
-- `expr` is the argument for `vim.fn.getchar`
function utils.feedkey_witharg(keys, expr)
	return function()
		vim.api.nvim_feedkeys("", "x", true)
		local arg = vim.fn.getcharstr()
		Vdbg("arg: " .. arg)
		keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
		Vdbg("keys: " .. keys)
		vim.api.nvim_feedkeys(keys, "n", true)
		vim.api.nvim_feedkeys(arg, "nx", true)
	end
end

function utils.find_first_pattern(str, patterns, start)
	local min_start_idx = math.huge
	local min_end_idx = nil
	local found_code = nil
	for i = 1, #patterns do
		local start_idx, end_idx = string.find(str, patterns[i], start)
		if start_idx ~= nil and start_idx < min_start_idx then
			min_start_idx = start_idx
			min_end_idx = end_idx
			found_code = patterns[i]
		end
	end
	if min_start_idx == math.huge then
		return nil, nil, nil
	else
		return min_start_idx, min_end_idx, found_code
	end
end

function utils.keys_amend_noremap_nowait(lhs, rhs, mode)
	keys_amend(mode, lhs, rhs, { noremap = true, nowait = true })
end

function utils.get_selection()
	local selection = {
		vim.fn.getpos("v"),
		vim.fn.getpos("."),
	}
	return selection
end

function utils.set_selection(selection)
	local start_pos, end_pos = selection[1], selection[2]
	local esc_tc = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
	local args = esc_tc .. start_pos[2] .. "G0"

	if start_pos[3] > 1 then
		args = args .. start_pos[3] - 1 .. "l"
	end
	args = args .. "v" .. end_pos[2] .. "G0"
	if end_pos[3] > 1 then
		args = args .. end_pos[3] - 1 .. "l"
	end
	vim.cmd("normal! " .. args)
end

-- decide which is the first position: start_pos or end_pos?
function utils.get_ordered_positions(start_pos, end_pos)
	local first_pos, second_pos
	if start_pos[2] > end_pos[2] then
		first_pos = end_pos
		second_pos = start_pos
	elseif start_pos[2] == end_pos[2] then
		if start_pos[3] > end_pos[3] then
			first_pos = end_pos
			second_pos = start_pos
		else
			first_pos = start_pos
			second_pos = end_pos
		end
	else
		first_pos = start_pos
		second_pos = end_pos
	end
	return first_pos, second_pos
end

function utils.enter(mode)
	if mode == "v" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
		vim.api.nvim_feedkeys("v", "n", false)
	elseif mode == "n" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
	end
end

function utils.mode_is_visual_arg(mode)
	vim.api.nvim_feedkeys("", "x", true)
	return mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode:sub(1, 1) == ""
end

function utils.mode_is_visual()
	vim.api.nvim_feedkeys("", "x", true)
	local mode = vim.fn.mode()
	Vdbg("Detected mode: " .. mode)
	return utils.mode_is_visual_arg(mode)
end

function utils.get_cursor()
	vim.api.nvim_feedkeys("", "x", true)
	return vim.api.nvim_win_get_cursor(0)
end

function utils.prequire(m)
	local ok, err = pcall(require, m)
	if not ok then
		return nil, err
	end
	return err
end

function utils.concat_arrays(arrays)
	local result = {}
	for i = 1, #arrays do
		for j = 1, #arrays[i] do
			table.insert(result, arrays[i][j])
		end
	end
	return result
end

function utils.play_keys(keys)
	-- keys is a string
	-- iterate each character and feed it to vim
	for i = 1, #keys do
		local char = keys:sub(i, i)
		vim.api.nvim_feedkeys(char, "mx", false)
	end
end

function utils.str_to_table(mode)
  -- mode may be a table or a single-character or multi-character string
  if type(mode) == "table" then
    return mode
  end

  if #mode == 1 then
    return { mode }
  end

  local t = {}
  mode:gsub(".", function (c) table.insert(t, c) end)
  return t
end

function utils.del_maps_if_start_lhs(mappings, lhs)
	local ret = false
	for _, mapping in ipairs(mappings) do
		-- if mapping.lhs starts with lhs
		if mapping.lhs:sub(1, #lhs) == lhs then
			Vdbg("Deleting mapping " .. mapping.lhs)
			vim.keymap.del(utils.str_to_table(mapping.mode), mapping.lhs)
			ret = true
		end
	end
	return ret
end

return utils
