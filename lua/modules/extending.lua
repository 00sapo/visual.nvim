-- local keys_amend = require("keymap-amend")
local keys_amend = require("modules.keymap-amend")
local utils = require("modules.utils")

local extending = {
	options = {
		guicursor = "a:hor100",
		keymaps = {
			toggle = "-",
			custom = {
				x = "<S-v>",
				X = "<C-v>",
				["<"] = function()
					require("visual").extending.avoid_next_exit = true -- this flag allows to force visual.nvim staying in extending mode even if the autocommand would exit it. When extending mode is entered, the nvim's visual mode is turned on, and it it turned off whenever nvim's visual mode is left. Here, we need to enter normal mode in order to feed keys properly. Re-entering extending mode after having feeded the keys doesn't work, (don't really know why, though)
					vim.api.nvim_feedkeys("<gv", "n", true)
				end,
				[">"] = function()
					require("visual").extending.avoid_next_exit = true
					vim.api.nvim_feedkeys(">gv", "n", true)
				end,
			},
			exit_before = {}, -- exit extending mode and then execute these commands
			exit_after = {}, -- execute these commands and then exit extending mode
			ignore = {},
		},
	},
}
extending.active = false
local exit_before = extending.options.keymaps.exit_before
local exit_after = extending.options.keymaps.exit_after
local custom = extending.options.keymaps.custom
local ignore = extending.options.keymaps.ignore
local toggle = extending.options.keymaps.toggle
local all_commands = utils.concat_arrays({ ignore, exit_before, exit_after })

local function get_amended(v)
	return function(original)
		extending.feedkeys(v, original)
	end
end

function extending:enter()
	if extending.active then
		return
	end
	extending.avoid_next_exit = false
	extending.active = true
	extending._old_mode = vim.fn.mode()
	extending._old_cursor = vim.o.guicursor
	-- Enter visual mode
	if not utils.mode_is_visual_arg(extending._old_mode) then
		-- we need to press <esc> to enter visual mode, so let's do it only if we
		-- are not in visual mode, otherwise we lose the selection
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>v", true, false, true), "n", false)
	end

	-- Change cursor
	vim.opt.guicursor = extending.options.guicursor

	-- backup mappings of visual mode
	extending._backup_mapping = utils.concat_arrays({ vim.api.nvim_buf_get_keymap(0, "v"), vim.api.nvim_get_keymap("v") })

	-- apply mappings for extending mode
	for k, v in pairs(custom) do
		vim.keymap.set("v", k, v, { silent = true, noremap = true })
	end
	for i = 1, #all_commands do
		keys_amend("v", all_commands[i], get_amended(all_commands[i]))
	end

	-- setup auto commands for exiting when mode changes from visual
	local gid = vim.api.nvim_create_augroup("VisualExtending", { clear = true })
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = gid,
		pattern = "*",
		callback = function()
			if not utils.mode_is_visual_arg(vim.v.event.new_mode) then
				require("visual").extending:exit()
			end
		end,
	})
end

function extending:exit()
	if not extending.active then
		return
	end
	if extending.avoid_next_exit then
		extending.avoid_next_exit = false
		return
	end
	extending.active = false
	-- reset cursor
	vim.o.guicursor = extending._old_cursor

	-- remove mappings for extending mode
	for k, _ in pairs(custom) do
		vim.keymap.del("v", k)
	end
	for i = 1, #all_commands do
		vim.keymap.del("v", all_commands[i])
	end

	-- reapply backed up commands
	for _, map in ipairs(extending._backup_mapping) do
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

  -- re-setup our commands (these shouldn't be needed, but...)
  require("visual").setup()
	end

	-- delete autocommands
	vim.api.nvim_del_augroup_by_name("VisualExtending")
end

function extending:toggle()
	if extending.active then
		extending:exit()
	else
		extending:enter()
	end
end

-- extending.keymaps["<esc>"] = function() extending:toggle() end

function extending.feedkeys(keys, original)
	if keys == toggle then
		return extending:toggle()
	end
	if vim.tbl_contains(ignore, keys) then
		return
	elseif vim.tbl_contains(exit_before, keys) then
		extending:exit()
	end

	original()

	if vim.tbl_contains(exit_after, keys) then
		extending:exit()
	end
end

return extending
