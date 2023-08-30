local history = require("visual.history")
local serendipity = require("visual.serendipity")
local utils = require("visual.utils")
local Vdbg = require("visual.debugging")
local mappings = {}

local function apply_key(key, countable, count)
	-- parse countability
	if countable == nil then
		if type(key) == "string" or type(key) == "function" or key.countable == nil then
			countable = true
		else
			countable = key.countable
		end
	end
	Vdbg("Parsing countability: " .. tostring(countable))

	-- apply keys with special codes replaced
	if type(key) == "table" then
		key = key["rhs"]
	end
	for _, el in ipairs(serendipity.serendipity_specialcodes(key)) do
		if type(el) == "function" then
			el()
		elseif type(el) == "string" then
			if countable and count > 1 then
				el = count .. el
			end
			Vdbg("Applying key: " .. el)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(el, true, false, true), "n", false)
		end
	end
end

-- Return a function that can be used as rhs in keys-amend.nvim
function mappings.make_rhs(keys, history_store)
	local pre_amend = keys.pre_amend or keys[1]
	local post_amend = keys.post_amend or keys[2]
	---@diagnostic disable-next-line: unused-local
	local mode = keys.mode or keys[3]
	local amend = keys.amend
	local countable = keys.countable
	if amend == nil then
		amend = false
	end

	local function f(original)
		local count = vim.v.count1
		for _, key in pairs(pre_amend) do
			apply_key(key, countable, count)
		end

		if amend then
			original()
		end

		for _, key in pairs(post_amend) do
			apply_key(key, countable, count)
		end

		-- if utils.mode_is_visual() then
		-- 	-- Save current selection to history
		--     local selection = utils.get_selection()
		--     Vdbg("Pushing selection: ", selection)
		-- 	history:push(selection)
		-- else
		-- 	Vdbg("not pushing")
		-- end
		if history_store then
			Vdbg("Storing last command: ")
			Vdbg(keys)
			history.last_command = keys
		end
	end
	return f
end

-- general mappings
function mappings.apply_mappings(opts)
	for name, lhs in pairs(opts.mappings) do
		if opts.commands[name] == nil then
			vim.notify("Visual.nvim: No mapping for " .. name)
		else
			local modes = opts.commands[name].modes or opts.commands[name][3]
			local rhs = mappings.make_rhs(opts.commands[name], not vim.tbl_contains(history.repeat_mapping_names, name))
			for i = 1, #modes do
				if modes[i] == serendipity.mode_value then
					serendipity.mappings[lhs] = rhs
				else
					utils.keys_amend_noremap_nowait(lhs, rhs, modes[i])
				end
			end
		end
	end
end

-- unmappings
function mappings.unmaps(opts, mode)
	local u = opts[mode .. "unmaps"]
	for _, v in ipairs(u) do
		vim.keymap.set(mode, v, function() end, { nowait = true })
		if mode == "v" then
			vim.keymap.set("x", v, function() end, { nowait = true })
		end
	end
end

return mappings
