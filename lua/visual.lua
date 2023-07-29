local visual = {}

Vdbg = require("modules.debugging")

local mappings = require("modules.mappings")
local history = require("modules.history")
local serendipity = require("modules.serendipity")
-- local compatibility = require("modules.compatibility")
local surround = require("modules.surround")
local motions = require("modules.motions")

visual.utils = require("modules.utils")
visual.mappings = mappings
visual.history = history
visual.serendipity = serendipity
visual.surround = surround

visual.options = {
	-- commands that will be unmapped from serendipity, normal, or visual mode (e.g. for forcing you learning new keymaps and/or avoiding conflicts)
	sdunmaps = {},
	vunmaps = {},
	nunmaps = { "W", "E", "B", "w", "e", "b", "y", "d", "c", "s", "gc", ">", "<" },
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
		append_at_cursor = "a", -- append at cursor position in visual mode
		insert_at_cursor = "i", -- insert at cursor position in visual mode
		sd_inside = "I", -- select inside from serendipity mode
		sd_around = "A", -- select around from serendipity mode
		-- line_visual = "x", -- enter line-visual mode
		-- block_visual = "<S-x>", -- enter block-visual mode
		-- delete_char = "y", -- delete char under cursor
		restart_visual = "'", -- collapse the visual selection to the char under cursor
		delete_single_char = "x", -- delete the char under cursor while in visual mode
		replace_single_char = "r", -- replace the char under cursor while in visual mode
		move_down_then_normal = "j", -- move down and enter normal mode
		move_up_then_normal = "k", -- move up and enter normal mode
		move_left_then_normal = "l", -- move left and enter normal mode
		move_right_then_normal = "h", -- move right and enter normal mode
		move_down_visual = "<a-j>", -- move down staying in visual mode
		move_up_visual = "<a-k>", -- move up staying in visual mode
		move_left_visual = "<a-l>", -- move left staying in visual mode
		move_right_visual = "<a-h>", -- move right staying in visual mode
		surround_change = "sc", -- change chars at the extremes of the selection
		surround_add = "sa", -- insert chars at the extremes of the selection
		surround_delete = "sd", -- delete chars at the extremes of the selection
		increase_indent = ">", -- increase indent in visual mode
		decrease_indent = "<", -- decrease indent in visual mode
		increase_indent_sd = ">", -- increase indent in serendipity mode
		decrease_indent_sd = "<", -- decrease indent in serendipity mode
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
        {rhs = "o", countable = false}
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_end_next = {
			pre_amend = {
				motions.WORD_start_next,
        {rhs = "o", countable = false}
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
        {rhs = "o", countable = false}
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		WORD_start_prev = {
			pre_amend = {
				motions.WORD_start_prev,
        {rhs = "o", countable = false}
			},
			post_amend = {},
			modes = { "n", "sd" },
		},
		toggle_serendipity = { pre_amend = { "<sdt>" }, post_amend = {}, modes = { "n", "sd", "v" }, countable = false },
		find_next = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "f" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		find_prev = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "F" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_next = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "t" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		till_prev = {
			pre_amend = { { rhs = "<esc>", countable = false }, { rhs = "v<sdi>", countable = false }, "T" },
			post_amend = {},
			modes = { "n", "sd" },
		},
		-- prev_selection = {
		-- 	pre_amend = {
		-- 		function()
		-- 			require("visual").history.set_history_prev()
		-- 		end,
		-- 	},
		-- 	post_amend = {},
		-- 	modes = { "n", "v" },
		-- },
		-- next_selection = {
		-- 	pre_amend = {
		-- 		function()
		-- 			require("visual").history.set_history_next()
		-- 		end,
		-- 	},
		-- 	post_amend = {},
		-- 	modes = { "n", "v" },
		-- },
		-- line_visual = {
		-- 	pre_amend = {
		-- 		"<sdi>V",
		-- 	},
		-- 	post_amend = {},
		-- 	modes = { "sd" },
		-- },
		-- block_visual = {
		-- 	pre_amend = {
		-- 		"<sdi><C-v>",
		-- 	},
		-- 	post_amend = {},
		-- 	modes = { "sd" },
		-- },

		-- mapping applied to normal mode only
		-- delete_char = { pre_amend = { "x" }, post_amend = {}, modes = { "n" } },
		-- mapping applied to visual mode only
		sd_around = { pre_amend = { "<esc>", "va<sdi>" }, post_amend = {}, modes = { "sd" }, countable = false },
		sd_inside = { pre_amend = { "<esc>", "vi<sdi>" }, post_amend = {}, modes = { "sd" }, countable = false },
		append_at_cursor = { pre_amend = { "<esc>", "a" }, post_amend = {}, modes = { "sd" }, countable = false },
		insert_at_cursor = { pre_amend = { "<esc>", "i" }, post_amend = {}, modes = { "sd" }, countable = false },
		surround_delete = {
			pre_amend = { '<cmd>lua require("visual").surround.delete()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_add = {
			pre_amend = { '<cmd>lua require("visual").surround.add()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		surround_change = {
			pre_amend = { '<cmd>lua require("visual").surround.change()<cr><sdi>' },
			post_amend = {},
			modes = { "v", "sd" },
			countable = false,
		},
		restart_visual = {
			pre_amend = { "<esc>", "<sde>", "<sdi>" },
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
		replace_single_char = { pre_amend = { "<esc>", "r" }, post_amend = {}, modes = { "sd" }, countable = false },
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
	},
}

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function visual.setup(options)
	if type(options) == "table" then
		visual.options = vim.tbl_deep_extend("force", visual.options, options)
	end
	serendipity.options = vim.tbl_deep_extend("force", serendipity.options, visual.options.serendipity)
	serendipity.unmappings = visual.options.sdunmaps
	history.history_size = visual.options.history_size
	mappings.unmaps(visual.options, "v")
	mappings.unmaps(visual.options, "n")
	mappings.apply_mappings(visual.options)
	-- if visual.options.treesitter_textobjects.enable then
	-- 	compatibility.treesitter_textobjects(
	-- 		visual.options.mappings.toggle_visual_mode,
	-- 		visual.options.mappings.visual_inside,
	-- 		visual.options.mappings.visual_around
	-- 	)
	-- end
end

return visual
