local visual = {}

local Vdbg = require("visual.debugging")

local mappings = require("visual.mappings")
local history = require("visual.history")
local serendipity = require("visual.serendipity")
-- local compatibility = require("visual.compatibility")
local surround = require("visual.surround")
local motions = require("visual.motions")
local utils = require("visual.utils")

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
	if type(options) == "table" then
		visual.options = vim.tbl_deep_extend("force", visual.options, options)
	end
	-- backup mappings
	visual._backup_mapping = utils.concat_arrays({ vim.api.nvim_get_keymap("v"), vim.api.nvim_get_keymap("n") })

	serendipity.options = vim.tbl_deep_extend("force", serendipity.options, visual.options.serendipity)
	serendipity.unmappings = visual.options.sdunmaps
	history.setup(visual.options)
	mappings.unmaps(visual.options, "v")
	mappings.unmaps(visual.options, "n")
	mappings.apply_mappings(visual.options)
	visual.enabled = true
	-- if visual.options.treesitter_textobjects.enable then
	-- 	compatibility.treesitter_textobjects(
	-- 		visual.options.mappings.toggle_visual_mode,
	-- 		visual.options.mappings.visual_inside,
	-- 		visual.options.mappings.visual_around
	-- 	)
	-- end
end

function visual.disable()
	if visual.enabled then
		-- delete visual.nvim mappings
		for name, lhs in pairs(visual.options.mappings) do
			-- changing modes so that it doesn't include `sd`
			local _modes = visual.options.commands[name].modes
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
		for _, map in ipairs(visual._backup_mapping) do
			map.rhs = map.rhs or ""
			-- local rhs = vim.api.nvim_replace_termcodes(map.rhs, true, true, true)
			local buf = map.buffer == 1
			local mode = map.mode
			if mode == " " then
				mode = "v"
			end
			vim.keymap.set(mode, map.lhs, map.rhs, {
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

visual.options = {
	-- commands that will be unmapped from serendipity, normal, or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
	sdunmaps = {},
	vunmaps = {},
	nunmaps = { "W", "E", "B", "w", "e", "b", "y", "d", "c", "gc" },
	history_size = 50, -- how many selections we should remember in the history
	serendipity = {}, -- options for serendipity mode
	mappings = {
		-- a list of command names and of their key-maps; what each command does is defined below
		WORD_end_next = "E", -- select next WORD (punctuation included), cursor at end, previous space included
		word_end_next = "e", -- same as E but without punctuation
		WORD_end_prev = "gE", -- same as E but for previous words
		word_end_prev = "ge", -- same as e but for previous words
		WORD_start_next = "W", -- select next word including next its space, cursor at beginning, with punctuation
		word_start_next = "w", -- same as W but without punctuation
		WORD_start_prev = "B", -- select previous WORD including its next space, with punctuation, cursor at beginnning
		word_start_prev = "b", -- same as B but without punctuation
		toggle_serendipity = "-", -- toggle visual mode, here to override possible mappings from other plugins
		find_next = "f", -- select to next char
		find_prev = "F", -- select to previous char
		till_next = "t", -- select till next char
		till_prev = "T", -- select till previous char
		start_line = "0", -- select to start of line
		start_text = "_", -- select to start of text
		end_line = "$", -- select to end of line
		append_at_cursor = "a", -- append at cursor position in visual mode
		insert_at_cursor = "i", -- insert at cursor position in visual mode
		sd_change = "c", -- change selection from serendipity mode (avoid clashing with nvim-cmp)
		sd_inside = "I", -- select inside from serendipity mode
		sd_around = "A", -- select around from serendipity mode
		line_visual = "d", -- enter line-visual mode
		-- block_visual = "<S-x>", -- enter block-visual mode
		-- delete_char = "y", -- delete char under cursor
		restart_visual = "'", -- collapse the visual selection to the char under cursor
		delete_single_char = "x", -- delete the char under cursor while in visual mode
		replace_single_char = "r", -- replace the char under cursor while in visual mode
		-- move_down_then_normal = "j", -- move down and enter normal mode
		-- move_up_then_normal = "k", -- move up and enter normal mode
		-- move_left_then_normal = "l", -- move left and enter normal mode
		-- move_right_then_normal = "h", -- move right and enter normal mode
		-- move_down_visual = "<a-j>", -- move down staying in visual mode
		-- move_up_visual = "<a-k>", -- move up staying in visual mode
		-- move_left_visual = "<a-l>", -- move left staying in visual mode
		-- move_right_visual = "<a-h>", -- move right staying in visual mode
		surround_change = "sc", -- change chars at the extremes of the selection
		surround_add = "sa", -- insert chars at the extremes of the selection
		surround_delete = "sd", -- delete chars at the extremes of the selection
		increase_indent = ">", -- increase indent in visual mode
		decrease_indent = "<", -- decrease indent in visual mode
		increase_indent_sd = ">", -- increase indent in serendipity mode
		decrease_indent_sd = "<", -- decrease indent in serendipity mode
		increase_indent_normal = ">", -- increase indent in normal mode
		decrease_indent_normal = "<", -- decrease indent in normal mode
		repeat_command = "<A-.>", -- repeat the last visual.nvim command
		repeat_edit = "<A-,>", -- repeat the last edit in visual and serendipity mode
		macro = "q", -- same as usual `q` key, but it also disables visual.nvim (see issue https://github.com/00sapo/visual.nvim/issues/7); must be re-enabled via :VisualEnable when finished playing with macros
		-- next_selection = "L", -- surf selection history forward
		-- prev_selection = "H", -- surf selection history backward
	},
	commands = { -- what each command name does
		-- 	example_command = {
		-- 		-- Send the following keys to standard nvim, this can also be a function, or of mix of strings and functions
		-- 		-- The `countable` parameter allows each command to be counted.
		-- 		-- It is true by default and can be specified at the whole command level or at each inner-level.
		-- 		-- In this second case, you need to use `rhs` key for the command value (string or function).
		-- 		-- The outer level has precedence on the inner level.
		-- 		-- If a command is a function, `countable` is ignored (you shoulkd take
		-- 		care of v:count in the function).
		-- 		countable = true,
		-- 		pre_amend = {
		-- 			{ rhs = "<esc>v", countable = false },
		-- 			{ rhs = "E<sdi>", countable = true },
		-- 		},
		-- 		-- <sdi> is a special code meaning "enter serendipity mode"
		-- 		-- similarly, you can use <sde> and <sdt> for exit and toggle serendipity mode
		-- 		post_amend = {}, -- Same as above, but run after the amended key (see the `amend` parameter below)
		-- 		modes = { "n", "sd" }, -- A list of modes where this command will be mapped; "sd" is serendipity mode
		-- 		amend = false, -- if `amend` is true, the lhs is run as mapped by other plugins or configs (thanks keys-amend.nvim!)
		-- 		-- You can also avoid the keys pre_amend, amend, post_amend, mode, and just use positional arguments. You can also avoid the `amend` parameter and it will default to false. Setting it to true may help avoiding collisions with other plugins.
		-- 	},

		word_end_next = {
			pre_amend = {
				motions.word_start_next,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_end_next = {
			pre_amend = {
				motions.WORD_start_next,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_end_prev = {
			pre_amend = {
				motions.word_start_prev,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_end_prev = {
			pre_amend = {
				motions.WORD_start_prev,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_start_next = {
			pre_amend = {
				motions.word_start_next,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_start_next = {
			pre_amend = {
				motions.WORD_start_next,
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		word_start_prev = {
			pre_amend = {
				motions.word_start_prev,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_start_prev = {
			pre_amend = {
				motions.WORD_start_prev,
				{ rhs = "o", countable = false },
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		toggle_serendipity = { pre_amend = { "<sdt>" }, post_amend = {}, modes = { "n", "sd", "v" }, countable = false },
		find_next = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "f" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		find_prev = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "F" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_next = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "t" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_prev = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "T" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		start_line = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "0" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		start_text = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "_" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		end_line = {
			pre_amend = { { rhs = "<esc><sdi>", countable = false }, "$" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		repeat_command = {
			pre_amend = { history.run_last_command },
			post_amend = {},
			modes = { "n", "sd", "v" },
		},
		repeat_edit = {
			pre_amend = { history.run_last_edit },
			post_amend = {},
			modes = { "sd", "v" },
		},
		prev_selection = {
			pre_amend = {
				history.set_history_prev,
			},
			post_amend = {},
			modes = { "n", "v", "sd" },
		},
		next_selection = {
			pre_amend = {
				history.set_history_next,
			},
			post_amend = {},
			modes = { "n", "v", "sd" },
		},
		line_visual = {
			pre_amend = { { rhs = "<sdi>V", countable = false } },
			post_amend = {},
			modes = { "n" },
		},

		-- mapping applied to normal mode only
		-- delete_char = { pre_amend = { "x" }, post_amend = {}, modes = { "n" } },
		-- mapping applied to visual mode only
		sd_change = { pre_amend = { "<sde>", "c" }, post_amend = {}, modes = { "sd" }, countable = false },
		sd_around = { pre_amend = { "<esc>", "<sdi>a" }, post_amend = {}, modes = { "sd" }, countable = false },
		sd_inside = { pre_amend = { "<esc>", "<sdi>i" }, post_amend = {}, modes = { "sd" }, countable = false },
		append_at_cursor = { pre_amend = { "<esc><sde>", "a" }, post_amend = {}, modes = { "sd" }, countable = false },
		insert_at_cursor = { pre_amend = { "<esc><sde>", "i" }, post_amend = {}, modes = { "sd" }, countable = false },
		surround_delete = {
			pre_amend = { surround.delete, "<sdi>o" },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_add = {
			pre_amend = { surround.add, "<sdi>o" },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_change = {
			pre_amend = { surround.change, "<sdi>o" },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		restart_visual = {
			pre_amend = { "<esc>v" },
			post_amend = {},
			modes = { "sd", "v" },
			countable = false,
		},
		delete_single_char = {
			pre_amend = { "<esc>", "xgv<sdi>" },
			post_amend = {},
			modes = { "sd" },
			countable = false,
		},
		replace_single_char = {
			pre_amend = { "<esc>", utils.feedkey_witharg("r", nil), "gv<sdi>" },
			post_amend = {},
			modes = { "sd" },
			countable = false,
		},
		macro = {
			pre_amend = {
				"<sde>",
        visual.disable
			},
			post_amend = {},
			modes = { "n", "v", "sd" },
			countable = false,
			amend = true,
		},
		-- move_down_then_normal = { pre_amend = { "j<esc>" }, post_amend = {}, modes = { "sd" } },
		-- move_up_then_normal = { pre_amend = { "k<esc>" }, post_amend = {}, modes = { "sd" } },
		-- move_left_then_normal = { pre_amend = { "l<esc>" }, post_amend = {}, modes = { "sd" } },
		-- move_right_then_normal = { pre_amend = { "h<esc>" }, post_amend = {}, modes = { "sd" } },
		-- move_down_visual = { pre_amend = { "j" }, post_amend = {}, modes = { "sd" } },
		-- move_up_visual = { pre_amend = { "k" }, post_amend = {}, modes = { "sd" } },
		-- move_left_visual = { pre_amend = { "l" }, post_amend = {}, modes = { "sd" } },
		-- move_right_visual = { pre_amend = { "h" }, post_amend = {}, modes = { "sd" } },
		decrease_indent = { pre_amend = { "<gv" }, post_amend = {}, modes = { "v" } },
		increase_indent = { pre_amend = { ">gv" }, post_amend = {}, modes = { "v" } },
		decrease_indent_sd = { pre_amend = { "<gv<sdi>" }, post_amend = {}, modes = { "sd" } },
		increase_indent_sd = { pre_amend = { ">gv<sdi>" }, post_amend = {}, modes = { "sd" } },
		decrease_indent_normal = { pre_amend = { "<<" }, post_amend = {}, modes = { "n" } },
		increase_indent_normal = { pre_amend = { ">>" }, post_amend = {}, modes = { "n" } },
	},
}

return visual
