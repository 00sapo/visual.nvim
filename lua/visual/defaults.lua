local surround = require("visual.surround")
local motions = require("visual.motions")
local history = require("visual.history")
local utils = require("visual.utils")

local M = {}
function M.get_defaults(visual)
	return {
		-- commands that will be unmapped from serendipity, normal, or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
		sdunmaps = {},
		vunmaps = {},
		nunmaps = { "W", "E", "B", "w", "e", "b", "y", "d", "c" },
		history_size = 50, -- how many selections we should remember in the history
		treesitter_textobjects = false,
		s_jumps = pcall(require, "leap"),
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
			restart_visual = "'", -- collapse the visual selection to the char under cursor
			restart_sd = "'", -- collapse the sd selection to the char under cursor
			delete_single_char = "x", -- delete the char under cursor while in visual mode
			replace_single_char = "r", -- replace the char under cursor while in visual mode
			surround_change = "zc", -- change chars at the extremes of the selection
			surround_add = "za", -- insert chars at the extremes of the selection
			surround_delete = "zd", -- delete chars at the extremes of the selection
			increase_indent = ">", -- increase indent in visual mode
			decrease_indent = "<", -- decrease indent in visual mode
			increase_indent_sd = ">", -- increase indent in serendipity mode
			decrease_indent_sd = "<", -- decrease indent in serendipity mode
			increase_indent_normal = ">", -- increase indent in normal mode
			decrease_indent_normal = "<", -- decrease indent in normal mode
			repeat_command = "<A-.>", -- repeat the last visual.nvim command
			repeat_edit = "<A-,>", -- repeat the last edit in visual and serendipity mode
			macro = "q", -- same as usual `q` key, but it also disables visual.nvim (see issue https://github.com/00sapo/visual.nvim/issues/7); must be re-enabled via :VisualEnable when finished playing with macros
			goto_definition = "gd", -- go to definition
			goto_last_pos = "<A-o>", -- move cursor to the last position before a visual key
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
			toggle_serendipity = {
				pre_amend = { "<sdt>" },
				post_amend = {},
				modes = { "n", "sd", "v" },
				countable = false,
			},
			find_next = {
				pre_amend = { { rhs = "<esc><sdi>", countable = false } },
				post_amend = {},
				modes = { "n", "sd" },
				amend = true,
			},
			find_prev = {
				pre_amend = { { rhs = "<esc><sdi>", countable = false } },
				post_amend = {},
				modes = { "n", "sd" },
				amend = true,
			},
			till_next = {
				pre_amend = { { rhs = "<esc><sdi>", countable = false } },
				post_amend = {},
				modes = { "n", "sd" },
				amend = true,
			},
			till_prev = {
				pre_amend = { { rhs = "<esc><sdi>", countable = false } },
				post_amend = {},
				modes = { "n", "sd" },
				amend = true,
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

			-- mapping applied to visual mode only
			sd_change = { pre_amend = { "<sde>", "c" }, post_amend = {}, modes = { "sd" }, countable = false },
			sd_around = { pre_amend = { "<esc>", "<sdi>a" }, post_amend = {}, modes = { "sd" }, countable = false },
			sd_inside = { pre_amend = { "<esc>", "<sdi>i" }, post_amend = {}, modes = { "sd" }, countable = false },
			append_at_cursor = {
				pre_amend = { "<esc><sde>", "a" },
				post_amend = {},
				modes = { "sd" },
				countable = false,
			},
			insert_at_cursor = {
				pre_amend = { "<esc><sde>", "i" },
				post_amend = {},
				modes = { "sd" },
				countable = false,
			},
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
				modes = { "v" },
				countable = false,
			},
			restart_sd = {
				pre_amend = { "<esc><sdi>" },
				post_amend = {},
				modes = { "sd" },
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
					visual.disable,
				},
				post_amend = {},
				modes = { "n", "v", "sd" },
				countable = false,
				amend = true,
			},
			decrease_indent = { pre_amend = { "<gv" }, post_amend = {}, modes = { "v" } },
			increase_indent = { pre_amend = { ">gv" }, post_amend = {}, modes = { "v" } },
			decrease_indent_sd = { pre_amend = { "<gv<sdi>" }, post_amend = {}, modes = { "sd" } },
			increase_indent_sd = { pre_amend = { ">gv<sdi>" }, post_amend = {}, modes = { "sd" } },
			decrease_indent_normal = { pre_amend = { "<<" }, post_amend = {}, modes = { "n" } },
			increase_indent_normal = { pre_amend = { ">>" }, post_amend = {}, modes = { "n" } },
			goto_definition = {
				pre_amend = { "<esc><sde>" },
				post_amend = {},
				modes = { "sd" },
				amend = true,
				countable = false,
			},
			goto_last_pos = {
				pre_amend = { history.goto_last_pos },
				post_amend = {},
				modes = { "n", "v", "sd" },
				amend = false,
				countable = false,
			},
		},
	}
end
return M
