local keys_amend = require("keymap-amend")

local extending = {
	options = {
		guicursor = "a:hor100",
		keymaps = {
			toggle = "-",
			custom = {
				x = "<S-v>",
				X = "<C-v>",
				["<esc>"] = function()
					require("visual").extending:exit()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
				end,
			},
			exit_before = { "a", "A", "i", "I", "c", "C", "o", "O" }, -- exit extending mode and then execute these commands
			exit_after = { "d", "p", "y", "P", "Y", "D", "gc" }, -- execute these commands and then exit extending mode
			ignore = {},
		},
	},
}
extending.active = false

local function get_amended(v)
	return function(original)
    print(original)
		extending.feedkeys(v, original)
	end
end

function extending:enter()
	extending.active = true
	extending._old_mode = vim.fn.mode()
	extending._old_cursor = vim.o.guicursor
	-- Enter visual mode
	if extending._old_mode ~= "v" and extending._old_mode ~= "V" and extending._old_mode ~= "" then
		-- we need to press <esc> to enter visual mode, so let's do it only if we
		-- are not in visual mode, otherwise we lose the selection
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>v", true, false, true), "n", false)
	end

	-- Change cursor
	vim.opt.guicursor = extending.options.guicursor

	-- apply mappings for extending mode
	for k, v in pairs(extending.options.keymaps.custom) do
		-- keys_amend("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
		vim.keymap.set("v", k, v, { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_before) do
		keys_amend("v", v, get_amended(v), { expr = true, silent = true, noremap = true })
		-- vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_after) do
		-- vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
		keys_amend("v", v, get_amended(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.ignore) do
		keys_amend("v", v, get_amended(v), { expr = true, silent = true, noremap = true })
		-- vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
end

function extending:exit()
	extending.active = false
	-- reset cursor
	vim.o.guicursor = extending._old_cursor

	-- remove mappings for extending mode
	for k, v in pairs(extending.options.keymaps.custom) do
		vim.keymap.del("v", k)
	end
	for _, v in ipairs(extending.options.keymaps.exit_before) do
		vim.keymap.del("v", v)
	end
	for _, v in ipairs(extending.options.keymaps.exit_after) do
		vim.keymap.del("v", v)
	end
	for _, v in ipairs(extending.options.keymaps.ignore) do
		vim.keymap.del("v", v)
	end

	-- reapply other keymaps
	-- WARNING: this is not correct, we should find a way to reset the keymaps
	-- backed up with vim.api.nvim_get_keymap('v')
	local visual = require("visual")
	visual.setup(visual.options)
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

	if keys == extending.options.keymaps.toggle then
		return extending:toggle()
	end
	if vim.tbl_contains(extending.options.keymaps.ignore, keys) then
		return
	elseif vim.tbl_contains(extending.options.keymaps.exit_before, keys) then
		extending:toggle()
	end

	original()

	if vim.tbl_contains(extending.options.keymaps.exit_after, keys) then
		extending:toggle()
	end
end

return extending
