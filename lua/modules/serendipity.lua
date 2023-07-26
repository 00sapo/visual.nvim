-- local keys_amend = require("keymap-amend")
local keys_amend = require("modules.keymap-amend")
local utils = require("modules.utils")

local M = {
	mode_value = "sd", -- special mode used in commands
	term_codes = { -- special codes used in commands
		toggle = "<sdt>",
		init = "<sdi>",
		exit = "<sde>",
	},
	mappings = {}, -- this table will be filled on apply_mappings (called during setup)
	unmappings = {}, -- same
	options = { -- filled from visual.options.serendipity
		guicursor = "a:hor100",
		highlight = "guibg=LightCyan guifg=none",
    v_got_to_visual = true -- if true, pressing v leads to visual mode, not to normal allows to select text objects like viw vaw
	},
}
M.active = false

-- returns a table representing the same input command as str but serendipity special codes are substituted with functions
function M.serendipity_specialcodes(str)
	-- splitting str by special codes
	local codes = vim.tbl_values(M.term_codes)
	local out = {}
	local prev_code_end = 0
	local next_code_start, next_code_end, code = utils.find_first_pattern(str, codes, 1)
	while code do
		table.insert(out, string.sub(str, prev_code_end + 1, next_code_start - 1))
		local func
		if code == M.term_codes.toggle then
			func = M.toggle
		elseif code == M.term_codes.init then
			func = function()
				M.avoid_next_exit = true
				M.init()
			end
		elseif code == M.term_codes.exit then
			func = M.exit
		end
		table.insert(out, function()
			func()
		end)
		prev_code_end = next_code_end
		next_code_start, next_code_end, code = utils.find_first_pattern(str, codes, prev_code_end + 1)
	end
	table.insert(out, string.sub(str, prev_code_end + 1, #str))

	return out
end

function M.init()
	if M.active then
		return
	end
	M.active = true
	M._old_mode = vim.fn.mode()
	M._old_cursor = vim.o.guicursor
	M._old_highlight = vim.api.nvim_exec2("hi Visual", { output = true }).output:gsub("xxx", "")

	-- Enter visual mode
	if not utils.mode_is_visual_arg(M._old_mode) then
		-- we need to press <esc> to enter visual mode, so let's do it only if we
		-- are not in visual mode, otherwise we lose the selection
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>v", true, false, true), "n", false)
	end
	-- Change cursor
	vim.opt.guicursor = M.options.guicursor

	-- changing highlight
	vim.cmd("hi Visual " .. M.options.highlight)

	-- backup mappings of visual mode
	M._backup_mapping = utils.concat_arrays({ vim.api.nvim_buf_get_keymap(0, "v"), vim.api.nvim_get_keymap("v") })

	-- unmap commands
	for i = 1, #M.unmappings do
		vim.keymap.del("v", M.unmappings[i])
	end

	-- apply mappings for serendipity mode
	for lhs, rhs in pairs(M.mappings) do
		utils.keys_amend_noremap_nowait(lhs, rhs, "v")
	end

  if M.options.v_got_to_visual then
    vim.keymap.set("v", "v", function() M.exit() end, {noremap = true, nowait = true})
  end

	-- setup auto commands for exiting when mode changes from visual
	local gid = vim.api.nvim_create_augroup("Visualserendipity", { clear = true })
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = gid,
		pattern = "*",
		callback = function()
			if not utils.mode_is_visual_arg(vim.v.event.new_mode) then
				require("visual").serendipity.exit()
			end
		end,
	})
end

function M.exit()
	if not M.active then
		return
	end
	if M.avoid_next_exit then
		M.avoid_next_exit = false
		return
	end
	M.active = false

	-- reset cursor and highlight
	vim.o.guicursor = M._old_cursor
	vim.cmd("hi " .. M._old_highlight)

	-- remove mappings for serendipity mode
	for lhs, _ in pairs(M.mappings) do
		vim.keymap.del("v", lhs)
	end

	-- reapply backed up commands
	for _, map in ipairs(M._backup_mapping) do
		map.rhs = map.rhs or ""
		-- local rhs = vim.api.nvim_replace_termcodes(map.rhs, true, true, true)
		local buf = map.buffer == 1
		local mode = map.mode
		if mode == " " then
			mode = "v"
		end
		vim.keymap.set(
			mode,
			map.lhs,
			map.rhs,
			{ noremap = map.noremap, silent = map.silent, nowait = map.nowait, callback = map.callback, buffer = buf }
		)
	end

	-- delete autocommands
	vim.api.nvim_del_augroup_by_name("Visualserendipity")
end

function M.toggle()
	if M.active then
		M.exit()
	else
		M.init()
	end
end

-- M.keymaps["<esc>"] = function() M:toggle() end

return M
