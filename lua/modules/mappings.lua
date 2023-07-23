local keys_amend = require("keymap-amend")

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

-- Return a function that can be used as rhs in keys-amend.nvim
local function make_rhs(keys, lhs)
	local pre_amend = keys.pre_amend or keys[1]
	local post_amend = keys.post_amend or keys[2]
	---@diagnostic disable-next-line: unused-local
	local mode = keys.mode or keys[3]
	local amend = keys.amend
  if amend == nil then
    amend = false
  end

	local function f(original)
		if extending.active then
			return extending:feedkeys(lhs)
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

		-- if utils.mode_is_visual() then
		-- 	-- Save current selection to history
		-- 	local selection = {
		-- 		vim.fn.getpos("v"),
		-- 		vim.fn.getpos("."),
		-- 	}
		-- 	history:push(selection)
		-- else
		-- 	print("not pushing")
		-- end
	end
	return f
end

-- general mappings
function mappings.apply_mappings(opts)
	for name, lhs in pairs(opts.mappings) do
		if opts.commands[name] == nil then
			print("Visual.nvim: No mapping for " .. name)
		else
			local modes = opts.commands[name].modes or opts.commands[name][3]
      for i = 1, #modes do
        keys_amend(modes[i], lhs, make_rhs(opts.commands[name], lhs), { noremap = true, silent = true })
      end
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

-- unmappings
function mappings.unmaps(opts, mode)
	local u = opts[mode .. "unmaps"]
	local nothing = function() end
	for _, v in pairs(u) do
		vim.keymap.set(mode, v, nothing, { remap = false })
    if mode == "v" then
      vim.keymap.set("x", v, nothing, { remap = false })
    end
	end
end

return mappings
