local keys_amend = require("modules.keymap-amend")

local utils = {}

function utils.feedkeys_noserendipityautocmd(m, k, r)
	local sd = require("modules.serendipity")
	-- print("avoiding next exit 3")
	sd.avoid_next_exit = true
	vim.api.nvim_feedkeys(m, k, r)
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
	local args = esc_tc .. start_pos[2] .. "G0" .. start_pos[3] .. "lv" .. end_pos[2] .. "G0" .. end_pos[3] .. "l"
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

return utils
