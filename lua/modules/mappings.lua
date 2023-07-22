local amend_func = require('keymap-amend')

local history = require("modules.history")
local extending = require("modules.extending")
local utils = require("modules.utils")
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

-- return a proper value for counting commands and remove the field `countable` from `opts`
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
  opts.countable = nil
	return counts
end

local function get_mapping_func(keys, mode, pressed_key)
  local pre_amend = keys.pre_amend or keys[1]
  local amend = keys.amend or keys[2]
  local post_amend = keys.post_amend or keys[3]

	local function f(original)
		if extending.active then
			return extending:feedkeys(pressed_key)
		end
    local counts = parse_counts(pre_amend)
    for _, key in pairs(pre_amend) do
      apply_key(key, counts)
    end

    if amend then
      original()
    end

    counts = parse_counts(post_amend)
    for _, key in pairs(post_amend) do
      apply_key(key, counts)
    end

		if utils.mode_is_visual() then
			-- Save current selection to history
			local selection = {
				vim.fn.getpos("v"),
				vim.fn.getpos("."),
			}
			history:push(selection)
    else
      print("not pushing")
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
			amend_func("n", v, get_mapping_func(c[k], "n", v), { noremap = true, silent = true })
			amend_func("v", v, get_mapping_func(c[k], "v", v), { noremap = true, silent = true })
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
		amend_func(mode, lhs, rhs, { noremap = true, silent = true })
	end
end

-- unmappings
function mappings.unmaps(opts)
	local u = opts.unmaps
	local nothing = function() end
	for _, v in pairs(u) do
		vim.keymap.set("n", v, nothing, { silent = true })
	end
end

return mappings
