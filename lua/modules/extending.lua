local extending = {
	options = {
		guicursor = "a:hor100",
		keymaps = {
			toggle = "-",
			custom = {
				x = "<S-v>",
				X = "<C-v>",
			},
			exit_before = { "a", "A", "i", "I", "c", "C", "o", "O" }, -- exit extending mode and then execute these commands
			exit_after = { "d", "p", "y", "P", "Y", "D" }, -- execute these commands and then exit extending mode
			ignore = { "<esc>" },
		},
	},
}
extending.active = false

local function get_feedkey(v)
	return function()
		extending:feedkeys(v)
	end
end

function extending.setup(options)
	vim.tbl_deep_extend("force", extending.options, options)
	-- apply mappings for extending mode
	for k, v in pairs(extending.options.keymaps.custom) do
		vim.keymap.set("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_before) do
		vim.keymap.set("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_after) do
		vim.keymap.set("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.ignore) do
		vim.keymap.set("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
end

local function enter()
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
		vim.keymap.set("v", k, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_before) do
		vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.exit_after) do
		vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
	for _, v in ipairs(extending.options.keymaps.ignore) do
		vim.keymap.set("v", v, get_feedkey(v), { expr = true, silent = true, noremap = true })
	end
end

local function exit()
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
  visual = require'visual'
  visual.setup(visual.options)
end

function extending:toggle()
	extending.active = not extending.active
	if extending.active then
		enter()
	else
		exit()
	end
end

-- extending.keymaps["<esc>"] = function() extending:toggle() end

function extending:feedkeys(keys)
	if mapped == extending.options.keymaps.toggle then
		return extending:toggle()
	end
	if vim.tbl_contains(extending.options.keymaps.ignore, keys) then
		return
	elseif vim.tbl_contains(extending.options.keymaps.exit_before, keys) then
		extending:toggle()
	end

	if extending.options.keymaps[keys] ~= nil then
		mapped = extending.options.keymaps[keys]
	else
		mapped = keys
	end
	if type(mapped) == "string" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapped, true, false, true), "n", false)
	elseif type(mapped) == "function" then
		keys()
	end

	if vim.tbl_contains(extending.options.keymaps.exit_after, keys) then
		extending:toggle()
	end
end

return extending
