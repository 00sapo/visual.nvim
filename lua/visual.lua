local visual = {}

local Vdbg = require("visual.debugging")

local mappings = require("visual.mappings")
local history = require("visual.history")
local serendipity = require("visual.serendipity")
local compatibility = require("visual.compatibility")
local utils = require("visual.utils")

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
	if not visual.enabled then
		Vdbg("Setting up visual.nvim")
		if type(options) == "table" then
			visual.options = vim.tbl_deep_extend("force", visual.options, options)
		end
		Vdbg("Setting up compatibility")
		if visual.options.treesitter_textobjects then
			compatibility.treesitter_textobjects(visual.options.mappings.sd_inside, visual.options.mappings.sd_around)
		end
		if visual.options.s_jumps then
			compatibility.s_jumps()
		end

		Vdbg("Backing up commands")
		-- backup mappings
		visual._backup_mapping = utils.concat_arrays({ vim.api.nvim_get_keymap("v"), vim.api.nvim_get_keymap("n") })

		Vdbg("Setting up everything")
		serendipity.options = vim.tbl_deep_extend("force", serendipity.options, visual.options.serendipity)
		serendipity.unmappings = visual.options.sdunmaps
		history.setup(visual.options)
		mappings.unmaps(visual.options, "v")
		mappings.unmaps(visual.options, "n")
		mappings.apply_mappings(visual.options)

		visual.enabled = true
	end
end

function visual.disable()
	if visual.enabled then
		-- delete visual.nvim mappings
		for name, lhs in pairs(visual.options.mappings) do
			-- changing modes so that it doesn't include `sd`
			local _modes = visual.options.commands[name].modes
			if _modes == nil then
				_modes = visual.options.commands[name][3]
			end
			local modes = {}
			for i = 1, #_modes do
				if _modes[i] ~= "sd" then
					table.insert(modes, _modes[i])
				end
			end
			if #modes > 0 then
				Vdbg("Deleting mapping " .. lhs .. " in mode " .. table.concat(modes, ","))
				vim.keymap.del(modes, lhs)
			end
		end
		for _, lhs in ipairs(visual.options.vunmaps) do
			Vdbg("Deleting mapping " .. lhs .. " in visual mode")
			pcall(function()
				vim.keymap.del("v", lhs)
			end)
			pcall(function()
				vim.keymap.del("x", lhs)
			end)
		end
		for _, lhs in ipairs(visual.options.nunmaps) do
			Vdbg("Deleting mapping " .. lhs .. " in normal mode")
			pcall(function()
				vim.keymap.del("n", lhs)
			end)
		end
		-- restore original mappings
		Vdbg("Restoring original mappings")
		for _, map in ipairs(visual._backup_mapping) do
			map.rhs = map.rhs or ""
			-- local rhs = vim.api.nvim_replace_termcodes(map.rhs, true, true, true)
			local buf = map.buffer == 1
			local mode = map.mode
			if mode == " " then
				mode = "v"
			end
			vim.keymap.set(utils.str_to_table(mode), map.lhs, map.rhs, {
				noremap = map.noremap,
				silent = map.silent,
				nowait = map.nowait,
				callback = map.callback,
				buffer = buf,
			})
		end
		visual.enabled = false
	end
end

visual.options = require("visual.defaults").get_defaults(visual)
return visual
