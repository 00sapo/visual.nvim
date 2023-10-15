-- Tools for improving compatibility with other plugins
local mappings = require("visual.mappings")
local serendipity = require("visual.serendipity")
local utils = require("visual.utils")
local Vdbg = require("visual.debugging")
local M = {}

function M.treesitter_textobjects(sd_inside, sd_around)
	local treesitter = utils.prequire("nvim-treesitter.configs")
	if treesitter then
		local select = treesitter.get_module("textobjects.select")
		if select then
			if not select.enable then
				vim.notify("Visual.nvim: treesitter-textobjects select is not enabled, have you enabled it?")
			else
				if select.keymaps then
					for key, query in pairs(select.keymaps) do
						local group
						if type(query) == "table" then
							query = query.query
							group = query.query_group
						else
							group = nil
						end
						local selection_mode = select.selection_modes[query] or "v"

						local func = function()
							Vdbg("Adding treesitter-textobjects keymap: " .. key)
							Vdbg("Selection mode: " .. selection_mode)
							require("nvim-treesitter.textobjects.select").select_textobject(
								query,
								group,
								selection_mode
							)
						end

						-- change the first character of key if i/a to
						local keys = {
							pre_amend = { "<esc>", "<sdi>", func },
							post_amend = {},
							mode = { "sd" },
							amend = false,
							countable = false,
						}
						-- if outer in key, then set key to sd_around
						local lhs = ""
						if string.find(query, "outer") then
							lhs = sd_around
						elseif string.find(query, "inner") then
							lhs = sd_inside
						end
						lhs = lhs .. key:sub(2)

						local rhs = mappings.make_rhs(keys, true, true)
						serendipity.mappings[lhs] = rhs
					end
				else
					vim.notify("Visual.nvim: treesitter-textobjects keymaps not found, have you set them up?")
				end
			end
		else
			vim.notify(
				"Visual.nvim: treesitter-textobjects selection is not available, have you installed nvim-treesitter-textobjects?"
			)
		end
	else
		vim.notify("Visual.nvim: treesitter enabled but not found, have you installed it? ")
	end
end

function M.s_jumps()
	Vdbg("Setting up s-jumps")
	local rhs = mappings.make_rhs({
		pre_amend = {
			{ rhs = "<esc><sdi>", countable = false },
		},
		post_amend = {},
		mode = { "n", "sd" }, -- not used, actually
		amend = true,
	}, true, true)
	-- serendipity mappings
	serendipity.mappings["s"] = rhs
	serendipity.mappings["S"] = rhs
	-- normal mappings
	utils.keys_amend_noremap_nowait("s", rhs, "n")
	utils.keys_amend_noremap_nowait("S", rhs, "n")
end

return M
