local history = {}
local Vdbg = require("visual.debugging")
history.repeat_mapping_names = {"repeat_command", "repeat_edit"}
history.last_command = nil
history.selection_history = {}
history.cur_history_idx = 0

local utils = require("visual.utils")
local serendipity = require("visual.serendipity")

function history.setup(opts)
	history.history_size = opts.history_size
end

function history.run_last_command(original)
	local make_rhs = require("visual.mappings").make_rhs
	if history.last_command == nil then
		return
	end
	local f = make_rhs(history.last_command, true)
	Vdbg("Running last command: ")
	Vdbg(history.last_command)
	return f(original)
end

local ffi = require("ffi")
ffi.cdef("char *get_inserted(void)")
local function ffi_get_inserted()
	return ffi.string(ffi.C.get_inserted())
end

function history.run_last_edit()
	Vdbg("Running last inserted")
	local inserted = ffi_get_inserted()
  Vdbg("inserted: " .. inserted)
	-- get the second character
	local edit_cmd = inserted:sub(2, 2)
	Vdbg("edit_cmd: " .. edit_cmd)
	-- a variable to keep track of where the cursor-position char should be
	-- re-inserted after copying the last edit
	local old_char_pos = "begin"
	if edit_cmd == "c" then
		vim.api.nvim_feedkeys("d", "nx", false)
		serendipity.exit()
		old_char_pos = "end"
	elseif edit_cmd == "i" then
		serendipity.exit()
		vim.api.nvim_feedkeys("i", "nx", false)
		old_char_pos = "end"
	elseif edit_cmd == "a" then
		serendipity.exit()
		vim.api.nvim_feedkeys("a", "nx", false)
		old_char_pos = "begin"
	elseif edit_cmd == "s" then
		vim.api.nvim_feedkeys("dx", "nx", false)
		old_char_pos = "begin"
	elseif edit_cmd == "S" then
		serendipity.exit()
		vim.api.nvim_feedkeys("0d$", "nx", false)
		old_char_pos = "end"
	end

	-- if it was and edit command, past the remaining part of the last edit
	-- N.B. this could also be taken from the inserted string above, but it is not
	-- standard
	local pos = utils.get_cursor(0) -- (1, 0)-indexed
	local dotreg = vim.fn.getreg(".")

	Vdbg("Setting current char to: " .. inserted)
	vim.api.nvim_buf_set_text(0, pos[1] - 1, pos[2], pos[1] - 1, pos[2], { dotreg })

  -- select the pasted text
  utils.set_selection({{nil, pos[1], pos[2]+1}, {nil, pos[1], pos[2] + #dotreg}})
end

return history
