local history = require("modules.history")
local extending = require("modules.extending")
local mappings = {}

local function apply_key(key, count)
	if type(key) == "function" then
		key()
	elseif type(key) == "string" then
		if count >= 1 then
			key = count .. key
		end
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
	end
end

local function parse_counts(opts)
	local countable, counts
	if opts.countable == nil then
		countable = true
	else
		countable = opts.countable
	end
	if countable then
		counts = vim.v.count
	else
		counts = 0
	end
	return counts
end

local function get_mapping_func(keys, mode, pressed_key)
	local real_keys, pre_keys
	if #keys == 2 then
		pre_keys = keys.pre_keys or keys[1]
		real_keys = keys.keys or keys[2]
	else
		pre_keys = false
		real_keys = keys[1]
	end

	local function f()
		if extending.active then
			return extending:feedkeys(pressed_key)
		end
		if type(pre_keys) == "table" then
			local counts = parse_counts(pre_keys)

			-- Save current selection to history
			local selection = {
				vim.fn.getpos("v"),
				vim.fn.getpos("."),
			}
			history.push_history(selection)

			-- Enter normal mode
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)

			-- pre-visual keys
			for _, key in pairs(pre_keys) do
				apply_key(key, counts)
			end
		end
		if type(real_keys) == "table" then
			-- Enter visual mode
			vim.api.nvim_feedkeys("v", "n", false)

			local counts = parse_counts(real_keys)

			-- visual keys
			for _, key in pairs(real_keys) do
				apply_key(key, counts)
			end
		end
	end
	return f
end

-- general mappings
function mappings.general_mappings(opts)
	local m = opts.mappings
	local c = opts.commands
	for k, v in pairs(m) do
		if c[k] == nil then
			print("No mapping for " .. k)
		else
			vim.keymap.set("n", v, get_mapping_func(c[k], "n", v), { noremap = true, silent = true })
			vim.keymap.set("v", v, get_mapping_func(c[k], "v", v), { noremap = true, silent = true })
		end
	end

	-- mapping the extending mode toggle
	vim.keymap.set("n", "-", function()
		extending:toggle()
	end, { noremap = true, silent = true })
	vim.keymap.set("v", "-", function()
		extending:toggle()
	end, { noremap = true, silent = true })
end

-- only visual or only normal mappings
function mappings.partial_mappings(opts, mode)
	local rhs, lhs, m
	local c = opts.commands
	if mode == "v" then
		m = opts.only_visual_mappings
	elseif mode == "n" then
		m = opts.only_normal_mappings
	end
	for k, v in pairs(m) do
		if type(v) == "table" then
			lhs = v[1]
			rhs = get_mapping_func(v[2], mode, lhs)
		elseif type(v) == "string" then
			if c[k] == nil then
				print("No mapping for " .. k)
			else
				lhs = v
				rhs = get_mapping_func(c[k], mode, lhs)
			end
		end
		vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
	end
end

-- unmappings
function mappings.unmaps(opts)
	local u = opts.unmaps
	local nothing = function() end
	for k, v in pairs(u) do
		vim.keymap.set("n", v, nothing, { silent = true })
	end
end

return mappings
